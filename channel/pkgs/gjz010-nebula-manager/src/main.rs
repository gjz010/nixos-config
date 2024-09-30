#![feature(exit_status_error)]
#![feature(try_blocks)]
use std::{borrow::Cow, collections::BTreeMap, fs::File, io::{Read, Write}, net::Ipv4Addr, os::fd::{AsFd, AsRawFd}, path::{Path, PathBuf}, process::Stdio, thread::{JoinHandle, Scope, ScopedJoinHandle}};

use anyhow::{anyhow, bail};
use cidr::{Cidr, Inet, Ipv4Cidr, Ipv4Inet};
use clap::Parser;
use itertools::Itertools;
use log::info;
use os_pipe::{PipeReader, PipeWriter};
use serde::{Deserialize, Serialize};

#[derive(Parser, Debug)]
enum NebulaManArgs{
    /// Exporting network.yaml to JSON data describing necessary network information to Nix.
    ExportJson{
        public_config: PathBuf,
        output_path: String
    },
    /// Merge a public config and a private config into configuration for one node.
    MergeConfig{
        public_config: PathBuf,
        private_config: PathBuf,
        hostname: String,
        ca_path: String,
        cert_path: String,
        cert_key_path: String,
        output_path: String
    },
    /// Sign new cert.
    RotateCert{
        /// network.yaml
        public_config: PathBuf,
        certroot: PathBuf,
        #[clap(long, default_value = "false")]
        force: bool,
        //#[clap(long, default_value = "true")]
        //use_sops: bool
    },
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct NebulaNetworkNixNodeConf{
    local_ip: String,
    lighthouse: bool,
    relay: bool
}
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct NebulaNetworkNixConf{
    network_name: String,
    tun_name: String,
    nodes: BTreeMap<String, NebulaNetworkNixNodeConf>
}

use serde_yml::{Mapping, Value as YAMLValue};
use tempfile::{tempdir, TempDir};
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct NebulaNetworkGlobalRoute{
    route: cidr::Ipv4Cidr,
    via: String
}
#[derive(Serialize, Deserialize, Debug)]
pub struct NebulaNetworkGlobal{
    cidr: Ipv4Cidr,
    external_routes: Vec<NebulaNetworkGlobalRoute>,
    #[serde(rename = "networkId")]
    network_id: String,
    settings: serde_yml::Mapping
}
#[derive(Serialize, Deserialize, Debug)]
pub struct NebulaNetworkNode{
    ip: Ipv4Inet,
    lighthouse: bool,
    relay: bool,
    #[serde(default = "default_yamlvalue")]
    config: serde_yml::Mapping
}
pub fn default_yamlvalue()->serde_yml::Mapping{
    serde_yml::Mapping { map: Default::default() }
}
#[derive(Serialize, Deserialize, Debug)]
pub struct NebulaNetworkYaml{
    #[serde(rename = "nebula-global")]
    global: NebulaNetworkGlobal,
    #[serde(rename = "nebula-nodes")]
    nodes: BTreeMap<String, NebulaNetworkNode>
}
impl NebulaNetworkYaml{
    pub fn tun_name(&self)->String{
        format!("nebula.{}", self.global.network_id)
    }
}

#[derive(Serialize, Deserialize, Debug)]
pub struct NebulaNetworkSecretGlobal{
    #[serde(rename = "domainRoot")]
    domain_root: String,
    #[serde(rename = "cloudflare-dyndns-token")]
    cloudflare_dyndns_token: String
}
#[derive(Serialize, Deserialize, Debug)]
pub struct NebulaNetworkSecretNode{
    #[serde(rename = "secretDomain")]
    secret_domain: String
}

#[derive(Serialize, Deserialize, Debug)]
pub struct NebulaNetworkSecretYaml{
    #[serde(rename = "nebula-secrets-global")]
    global: NebulaNetworkSecretGlobal,
    #[serde(rename = "nebula-secrets-nodes")]
    nodes: BTreeMap<String, NebulaNetworkSecretNode>
}
impl NebulaNetworkSecretYaml{
    pub fn secret_domain(&self, node: &str)->String{
        format!("{}.{}", self.nodes.get(node).unwrap().secret_domain, self.global.domain_root)
    }
}

pub fn load_public_configuration<P: AsRef<Path>>(public_config: P)->anyhow::Result<NebulaNetworkYaml>{
    let config_file = std::fs::File::open(public_config.as_ref())?;
    let mut config: NebulaNetworkYaml = serde_yml::from_reader(config_file)?;
    // verify: all ip lies in cidr
    for (node, node_cfg) in config.nodes.iter_mut(){
        if !config.global.cidr.contains(&node_cfg.ip.address()){
            anyhow::bail!("Node {} has IP {} not in CIDR {}", node, node_cfg.ip, config.global.cidr);
        }else{
            node_cfg.ip = Ipv4Inet::new(node_cfg.ip.address(), config.global.cidr.network_length())?;
        }
    }
    Ok(config)
}
pub fn load_secret_configuration<P: AsRef<Path>>(private_config: P)->anyhow::Result<NebulaNetworkSecretYaml>{
    let config_file = std::fs::File::open(private_config.as_ref())?;
    let config: NebulaNetworkSecretYaml = serde_yml::from_reader(config_file)?;
    Ok(config)
}

pub fn recursive_merge(a: &mut serde_yml::Mapping, b: &serde_yml::Mapping)->(){
    for (key, value) in b.iter(){
        match (a.get_mut(key), value){
            (Some(YAMLValue::Mapping(ma)), YAMLValue::Mapping(mb)) => {
                recursive_merge(ma, mb);
            }
            (_a, b) =>{
                a.insert(key.clone(), b.clone());
            }
        }
    }
}

pub fn read_sops_encrypted<P: AsRef<Path>>(path: P)->anyhow::Result<String>{
    // invoke sops
    let mut output = std::process::Command::new("sops").arg("-d").arg(path.as_ref()).stdout(Stdio::piped()).spawn()?;
    let stdout_pipe = output.stdout.as_mut().unwrap();
    let mut s = String::new();
    stdout_pipe.read_to_string(&mut s)?;
    output.wait()?;
    Ok(s)
}
pub fn write_sops_encrypted<'a, P: AsRef<Path>>(path: P, s: &'a str)->anyhow::Result<()>{
    let mut f = std::fs::File::create(path.as_ref())?;
    f.write_all(s.as_bytes())?;
    drop(f);
    // invoke sops
    std::process::Command::new("sops").arg("-e").arg("--in-place").arg(path.as_ref()).spawn()?.wait()?.exit_ok()?;
    Ok(())
}

struct ScopedReadingPipe<'scope>{
    tempfile: tempfile::NamedTempFile,
    handle: ScopedJoinHandle<'scope, ()>
}
impl<'scope> ScopedReadingPipe<'scope>{
    pub fn new<'env>(scope: &'scope Scope<'scope, 'env>, buf: &'env [u8])->anyhow::Result<Self>{
        let tempfile = tempfile::NamedTempFile::new()?;
        let mut writer: File = tempfile.as_fd().try_clone_to_owned()?.into();
        let handle = scope.spawn(move || {
            writer.write_all(buf).unwrap();
            drop(writer);
        });
        Ok(Self{
            tempfile,
            handle
        })
    }
    pub fn reader_path(&self)->PathBuf{
        self.tempfile.path().to_path_buf()
    }
}

struct ScopedWritingPipe<'scope>{
    tempdir: TempDir,
    handle: ScopedJoinHandle<'scope, Vec<u8>>
}
impl<'scope> ScopedWritingPipe<'scope>{
    pub fn new<'env>(scope: &'scope Scope<'scope, 'env>)->anyhow::Result<Self>{
        let tempdir = tempdir()?;
        let tempfile_path = tempdir.path().join("empty");
        let s = tempfile_path.clone();
        let handle = scope.spawn(move || {
            while !s.exists(){
                //println!("waiting for file to exist");
                std::thread::sleep(std::time::Duration::from_millis(100));
            }
            let mut buf = vec![];
            File::open(s).unwrap().read_to_end(&mut buf).unwrap();
            buf
        });
        Ok(Self{
            tempdir,
            handle
        })
    }
    pub fn join(self)->anyhow::Result<Vec<u8>>{
        Ok(self.handle.join().unwrap())
    }
    pub fn writer_path(&self)->PathBuf{
        self.tempdir.path().join("empty")
    }
}

struct NebulaCert;
impl NebulaCert{
    pub fn verify_ca(cafile: &str, cakey: &str)->anyhow::Result<bool>{
        return Ok(true);
        Self::verify_cert(cafile, cafile, cakey) // TODO
    }
    pub fn verify_cert(cafile: &str, cert: &str, key: &str)->anyhow::Result<bool>{
        std::thread::scope(|s| {
            let ca_pipe = ScopedReadingPipe::new(s, cafile.as_bytes())?;
            let cert_pipe = ScopedReadingPipe::new(s, cert.as_bytes())?;
            let key_pipe = ScopedReadingPipe::new(s, key.as_bytes())?;
            let output = std::process::Command::new("nebula-cert").arg("verify").arg("-ca").arg(ca_pipe.reader_path())
            .arg("-crt").arg(cert_pipe.reader_path()).spawn()?.wait()?;
            Ok(output.success())
        })
    }
    pub fn generate_ca(name: &str)->anyhow::Result<(String, String)>{
        std::thread::scope(|s| {
            let ca_pipe = ScopedWritingPipe::new(s)?;
            let ca_key = ScopedWritingPipe::new(s)?;
            std::process::Command::new("nebula-cert").arg("ca").arg("-name").arg(name)
            .arg("-out-crt").arg(&ca_pipe.writer_path()).arg("-out-key").arg(&ca_key.writer_path()).spawn()?.wait()?.exit_ok()?;
            Ok((String::from_utf8(ca_pipe.join()?)?, String::from_utf8(ca_key.join()?)?))
        })

    }
    pub fn generate_cert(name: &str, ip: &str, subnets: &str, cafile: &str, cakey: &str)-> anyhow::Result<(String, String)>{
        std::thread::scope(|s| {
            let ca_pipe = ScopedReadingPipe::new(s, cafile.as_bytes())?;
            let ca_key_pipe = ScopedReadingPipe::new(s, cakey.as_bytes())?;
            let cert_pipe = ScopedWritingPipe::new(s)?;
            let key_pipe = ScopedWritingPipe::new(s)?;
            std::process::Command::new("nebula-cert").arg("sign").arg("-name").arg(name)
            .arg("-ip").arg(ip)
            .arg("-subnets").arg(subnets)
            .arg("-ca-crt").arg(ca_pipe.reader_path()).arg("-ca-key").arg(ca_key_pipe.reader_path())
            .arg("-out-crt").arg(cert_pipe.writer_path()).arg("-out-key").arg(key_pipe.writer_path()).spawn()?.wait()?.exit_ok()?;
            Ok((String::from_utf8(cert_pipe.join()?)?, String::from_utf8(key_pipe.join()?)?))
        })
    }
    pub fn verify_or_generate_ca_encrypted(cacert_path: &Path, cakey_path: &Path, name: &str)->anyhow::Result<(String, String)>{
        if cacert_path.exists() && cakey_path.exists(){
            let cacert = read_sops_encrypted(&cacert_path)?;
            let cakey = read_sops_encrypted(&cakey_path)?;
            if NebulaCert::verify_ca(&cacert, &cakey)?{
                return Ok((cacert, cakey));
            }
        }
        let (cacert, cakey) = NebulaCert::generate_ca(name)?;
        write_sops_encrypted(cacert_path, &cacert)?;
        write_sops_encrypted(cakey_path, &cakey)?;
        Ok((cacert, cakey))
    }
    pub fn verify_or_generate_cert_encrypted(cacert: &(String, String), cert_path: &Path, key_path: &Path, name: &str, ip: &str, subnets: &str)->anyhow::Result<(String, String)>{
        if cert_path.exists() && key_path.exists(){
            let cert = read_sops_encrypted(&cert_path)?;
            let key = read_sops_encrypted(&key_path)?;
            if NebulaCert::verify_cert(&cacert.0, &cert, &key)?{
                info!("Cert Verified.");
                return Ok((cert, key));
            }
        }
        let (cert, key) = NebulaCert::generate_cert(name, ip, subnets, &cacert.0, &cacert.1)?;
        write_sops_encrypted(cert_path, &cert)?;
        write_sops_encrypted(key_path, &key)?;
        Ok((cert, key))
    }
}


fn main() ->anyhow::Result<()>{
    env_logger::init();
    let args = NebulaManArgs::parse();
    match &args{
        NebulaManArgs::ExportJson { public_config, output_path } => {
            let config = load_public_configuration(public_config)?;
            let mut nodes = BTreeMap::default();
            for (node, node_cfg) in config.nodes.iter(){
                nodes.insert(node.to_owned(), NebulaNetworkNixNodeConf{
                    local_ip: node_cfg.ip.address().to_string(),
                    lighthouse: node_cfg.lighthouse,
                    relay: node_cfg.relay,
                });
            }
            let tun_name = config.tun_name();
            let out_config = NebulaNetworkNixConf{
                network_name: config.global.network_id,
                nodes,
                tun_name
            };
            let mut file = std::fs::File::create(output_path)?;
            serde_json::to_writer_pretty(&mut file, &out_config)?;
        }
        NebulaManArgs::MergeConfig { public_config, private_config, hostname, ca_path, cert_path, cert_key_path, output_path} => {
            let public_config = load_public_configuration(&public_config)?;
            let private_config = load_secret_configuration(&private_config)?;
            let mut new_config = default_yamlvalue();
            let curr_node = public_config.nodes.get(hostname).ok_or_else(| | anyhow!("Host {} not found", hostname) )?;
            // insert ca
            new_config.insert("pki".into(), vec![
                ("ca", ca_path),
                ("cert", cert_path),
                ("key", cert_key_path)
            ].into_iter().map(|x| (x.0.to_owned().into(), x.1.to_owned().into())).collect::<Mapping>().into());
            // connect all nodes to all lighthouses
            let mut lighthouse_connections = default_yamlvalue();
            
            for (lighthouse, node_cfg) in public_config.nodes.iter().filter(|x| x.1.lighthouse && x.0 != hostname){
                let domain = format!("{}:4242", private_config.secret_domain(lighthouse));
                let domainv6 = format!("ipv6.{}:4242", private_config.secret_domain(lighthouse));
                lighthouse_connections.insert(node_cfg.ip.address().to_string().into(), vec![YAMLValue::from(domain), domainv6.into()].into());
            }
            let mut lighthouse_cfg = vec![
                ("am_lighthouse".into(), curr_node.lighthouse.into())
            ];
            if !curr_node.lighthouse{
                lighthouse_cfg.push(("hosts".into(), lighthouse_connections.keys().cloned().collect_vec().into()));
            }
            new_config.insert("lighthouse".into(), lighthouse_cfg.into_iter().collect::<Mapping>().into());
            new_config.insert("static_host_map".into(), lighthouse_connections.into());
            // relays
            if curr_node.relay{
                // a relay
                new_config.insert("relay".into(), vec![
                    ("am_relay".into(), true.into())
                ].into_iter().collect::<Mapping>().into());
            }else{
                let mut relays: Vec<String> = vec![];
                for (_relay, node_cfg) in public_config.nodes.iter().filter(|x| x.1.relay){
                    relays.push(node_cfg.ip.address().to_string().into());
                }
                new_config.insert("relay".into(), vec![
                    ("am_relay".into(), false.into()),
                    ("relays".into(), relays.into())
                ].into_iter().collect::<Mapping>().into());
            }

            
            // unsafe_routes
            let internal_routes: Vec<BTreeMap<&'static str, String>> = public_config.global.external_routes.iter().filter(|y| y.via != *hostname).map(|y| {
                let x: anyhow::Result<BTreeMap<&'static str, String>> = try{([
                    ("route", y.route.to_string()),
                    ("via", public_config.nodes.get(y.via.as_str()).ok_or_else(| | anyhow!("Host {} not found", hostname))?.ip.address().to_string())
                ]).into_iter().collect()};
                x
            }).collect::<anyhow::Result<_>>()?;

            // listen
            new_config.insert("listen".into(), vec![
                ("host".into(), "::".into()),
                ("port".into(), 4242.into())
            ].into_iter().collect::<Mapping>().into());
            
            new_config.insert("tun".into(), vec![
                ("dev".into(), public_config.tun_name().into()),
                ("unsafe_routes".into(), serde_yml::to_value(internal_routes)?)
            ].into_iter().collect::<Mapping>().into());

            recursive_merge(&mut new_config, &public_config.global.settings);
            recursive_merge(&mut new_config, &curr_node.config);
            let mut file = std::fs::File::create(output_path)?;
            serde_yml::to_writer(&mut file, &new_config)?;
        }
        NebulaManArgs::RotateCert { public_config, certroot, force } => {
            std::fs::create_dir_all(certroot)?;
            let node_cert_path = certroot.join("certs");
            let node_key_path = certroot.join("keys");
            std::fs::create_dir_all(&node_cert_path)?;
            std::fs::create_dir_all(&node_key_path)?;
            info!("Rotating CA");
            let config = load_public_configuration(public_config)?;
            let ca_path = certroot.join("ca.crt");
            let ca_key_path = certroot.join("ca.key");
            let cacert = NebulaCert::verify_or_generate_ca_encrypted(&ca_path, &ca_key_path, &config.global.network_id)?;


            // show it
            //std::process::Command::new("nebula-cert").arg("print").arg("-path").arg(&ca_path).spawn()?.wait()?.exit_ok()?;

            for (node, node_cfg) in config.nodes.iter(){
                info!("Rotating cert for node {}", node);
                let mut subnets = vec![];
                for route in config.global.external_routes.iter(){
                    if &route.via == node{
                        subnets.push(route.route.to_string());
                    }
                }
                let node_cert = node_cert_path.join(node).with_extension("crt");
                let node_key = node_key_path.join(node).with_extension("key");

                let node_cert = NebulaCert::verify_or_generate_cert_encrypted(&cacert, &node_cert, &node_key, &*node, &node_cfg.ip.to_string(), &subnets.join(","))?;
                // show it
                //std::process::Command::new("nebula-cert").arg("print").arg("-path").arg(&node_cert).spawn()?.wait()?.exit_ok()?;
            }
        }
        
    }
    Ok(())
}
