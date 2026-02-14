{ config, pkgs, ... }:
let
  ipv6ULA = "fdba:0d62:d7d4::/48";
  nebulaCIDR = "fdba:0d62:d7d4:0001::/64";
  ipPoolCIDR = "fdba:0d62:d7d4:0002::/64";
  allPodCIDR = "fdba:0d62:d7d4:0100::/56";
  # nodePodCIDR = "fdba:0d62:d7d4:0101::/64";
  serviceCIDR = "fdba:0d62:d7d4:0003::/112";

in
{
  networking.jool.enable = true;

  #services.avahi.enable = true;
  #services.avahi.nssmdns4 = true;
  environment.systemPackages = [ pkgs.cilium-cli ];
  services.k3s = {
    enable = false;
    role = "server";
    extraFlags = [
      "--flannel-backend=none"
      "--disable-network-policy"
      "--disable=traefik"
      "--disable=servicelb"
      "--cluster-cidr=${allPodCIDR}"
      "--service-cidr=${serviceCIDR}"
    ];
    environmentFile = pkgs.writeText "k3s.env" ''
      HTTP_PROXY=http://192.168.76.1:30086
      HTTPS_PROXY=http://192.168.76.1:30086
      NO_PROXY=127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
      CONTAINERD_HTTP_PROXY=http://192.168.76.1:30086
      CONTAINERD_HTTPS_PROXY=http://192.168.76.1:30086
      CONTAINERD_NO_PROXY=127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
    '';
    autoDeployCharts = {
      cert-manager = {
        repo = "https://charts.jetstack.io";
        name = "cert-manager";
        version = "v1.19.0";
        hash = "sha256-tYFjQGkVH86Ac9DgjUVOcS2vf5v7nfALNdX9y6AZNrg=";
        targetNamespace = "cert-manager";
        createNamespace = true;
        values = {
          crds.enabled = true;
        };
      };
      cilium = {
        repo = "https://helm.cilium.io/";
        name = "cilium";
        version = "v1.18.2";
        hash = "sha256-ObYqcvCJLdFlSL0I7pfV2y6XX3wfVxVVeKFEGG4imS8=";
        targetNamespace = "cilium";
        createNamespace = true;
        values = {
          operator.replicas = 1;
          cni.exclusive = false;
        };
      };
      istio-base = {
        repo = "https://istio-release.storage.googleapis.com/charts";
        name = "base";
        version = "v1.27.2";
        hash = "";
        targetNamespace = "istio-system";
        createNamespace = true;
      };
      istiod = {
        repo = "https://istio-release.storage.googleapis.com/charts";
        name = "istiod";
        version = "v1.27.2";
        hash = "";
        targetNamespace = "istio-system";
        createNamespace = true;
        values = {
          profile = "ambient";
        };
      };
      istio-cni = {
        repo = "https://istio-release.storage.googleapis.com/charts";
        name = "cni";
        version = "v1.27.2";
        hash = "";
        targetNamespace = "istio-system";
        createNamespace = true;
        values = {
          profile = "ambient";
        };
      };
      ztunnel = {
        repo = "https://istio-release.storage.googleapis.com/charts";
        name = "ztunnel";
        version = "v1.27.2";
        hash = "";
        targetNamespace = "istio-system";
        createNamespace = true;
      };
      rancher = {
        repo = "https://releases.rancher.com/server-charts/latest";
        name = "rancher";
        version = "v2.12.2";
        hash = "sha256-v8ybwovsnXFjKa2rwKNsqY1pk+rywa3ByeghQOIA0YI=";
        targetNamespace = "cattle-system";
        createNamespace = true;
        values = {
          hostname = "rancher.homelab.gjz010.com";
        };
        extraFieldDefinitions = {
          spec.helmChartConfig.spec.chart = ''
            apiVersion: helm.cattle.io/v1
            kind: HelmChartConfig
            metadata:
              name: cert-manager
              namespace: kube-system
            spec:
              valuesContent: ""
          '';
        };
      };
    };
  };

}
