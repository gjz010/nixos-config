#![feature(exit_status_error)]
use std::{collections::BTreeMap, fs::File, net::Ipv4Addr, path::{Path, PathBuf}};

use anyhow::{anyhow, bail};
use cidr::{Cidr, Inet, Ipv4Cidr, Ipv4Inet};
use clap::Parser;
use itertools::Itertools;
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
        #[clap(long, default_value = "true")]
        use_sops: bool
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
    nodes: BTreeMap<String, NebulaNetworkNixNodeConf>
}

use serde_yml::{Mapping, Value as YAMLValue};
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
    global: NebulaNetworkGlobal,
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
    domain_root: String
}
#[derive(Serialize, Deserialize, Debug)]
pub struct NebulaNetworkSecretNode{
    #[serde(rename = "secretDomain")]
    secret_domain: String
}

#[derive(Serialize, Deserialize, Debug)]
pub struct NebulaNetworkSecretYaml{
    global: NebulaNetworkSecretGlobal,
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
/*
pub fn verify_cert(ca: Option<(&File, &File)>)->anyhow::Result<Option<(SopsEncryptedBinaryFile, SopsEncryptedBinaryFile)>>{

}
*/


fn main() ->anyhow::Result<()>{
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
            let out_config = NebulaNetworkNixConf{
                network_name: config.global.network_id,
                nodes
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
            new_config.insert("relay".into(), vec![
                ("am_relay".into(), curr_node.relay.into())
            ].into_iter().collect::<Mapping>().into());
            
            // unsafe_routes
            let internal_routes: Vec<BTreeMap<&'static str, String>> = public_config.global.external_routes.iter().filter(|y| y.via != *hostname).map(|y| {
                [   
                    ("route", y.route.to_string()),
                    ("via", y.via.to_owned())
                ].into_iter().collect()
            }).collect();
            
            new_config.insert("tun".into(), vec![
                ("dev".into(), public_config.tun_name().into()),
                ("unsafe_routes".into(), serde_yml::to_value(internal_routes)?)
            ].into_iter().collect::<Mapping>().into());

            recursive_merge(&mut new_config, &public_config.global.settings);
            recursive_merge(&mut new_config, &curr_node.config);
            let mut file = std::fs::File::create(output_path)?;
            serde_yml::to_writer(&mut file, &new_config)?;
        }
        NebulaManArgs::RotateCert { public_config, certroot, force, use_sops: bool } => {
            let config = load_public_configuration(public_config)?;
            let ca_path = certroot.join("ca.crt");
            let ca_key_path = certroot.join("ca.key");
            if *force{
                if ca_path.exists(){
                    std::fs::remove_file(&ca_path)?;
                }
                if ca_key_path.exists(){
                    std::fs::remove_file(&ca_key_path)?;
                }
            }
            // spawn nebula-cert
            std::process::Command::new("nebula-cert").arg("ca").arg("-name").arg(config.global.network_id)
            .arg("-out-crt").arg(&ca_path).arg("-out-key").arg(&ca_key_path).spawn()?.wait()?.exit_ok()?;
            // show it
            std::process::Command::new("nebula-cert").arg("print").arg("-path").arg(&ca_path).spawn()?.wait()?.exit_ok()?;
            let node_cert_path = certroot.join("certs");
            let node_key_path = certroot.join("keys");
            std::fs::create_dir_all(&node_cert_path)?;
            std::fs::create_dir_all(&node_key_path)?;
            for (node, node_cfg) in config.nodes.iter(){
                let mut subnets = vec![];
                for route in config.global.external_routes.iter(){
                    if &route.via == node{
                        subnets.push(route.route.to_string());
                    }
                }
                let node_cert = node_cert_path.join(node).with_extension(".crt");
                let node_key = node_key_path.join(node).with_extension(".key");
                if *force{
                    if node_cert.exists(){
                        std::fs::remove_file(&node_cert)?;
                    }
                    if node_key.exists(){
                        std::fs::remove_file(&node_key)?;
                    }
                }
                std::process::Command::new("nebula-cert").arg("sign").arg("-name").arg(node)
                .arg("-ip").arg(&node_cfg.ip.to_string())
                .arg("-subnets").arg(subnets.iter().join(","))
                .arg("-ca-crt").arg(&ca_path).arg("-ca-key").arg(&ca_key_path)
                .arg("-out-crt").arg(&node_cert).arg("-out-key").arg(&node_key).spawn()?.wait()?.exit_ok()?;
                
                // show it
                std::process::Command::new("nebula-cert").arg("print").arg("-path").arg(&node_cert).spawn()?.wait()?.exit_ok()?;
            }
        }
        
    }
    Ok(())
}
