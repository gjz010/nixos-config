{ lib, pkgs, config, ... }:
let
  wifi = "wlan0";
  eth = "end0";
  ethInternal = "enp1s0u2c2";
  ipAddress = "192.168.76.1";
  ipAddress1 = "192.168.77.1";
  prefixLength = 24;
  ip6Address = "fd56:7142:ec68::1";
  ip6Address1 = "fd56:7142:ec69::1";
  ip6PrefixLength = 48;
  servedAddressRange = "192.168.76.3,192.168.76.150,24h";
  ip6ServedAddressRange = "fd56:7142:ec68::3,fd56:7142:ec68::150,ra-names,24h";
  servedAddressRange1 = "192.168.77.3,192.168.77.150,24h";
  ip6ServedAddressRange1 = "fd56:7142:ec69::3,fd56:7142:ec69::150,ra-names,24h";
  ssid = "gjz010-nixos-pi";
  vpn-dev = "tun0";
in
{
  sops.templates."router-hostapd.conf".content = ''
    interface=${wifi}
    #hw_mode=a
    hw_mode=g
    #channel=36
    channel=1
    ieee80211d=1
    country_code=CN
    ieee80211n=1
    ieee80211ac=1
    wmm_enabled=1
    ssid=${ssid}
    auth_algs=1
    wpa=2
    wpa_key_mgmt=WPA-PSK
    rsn_pairwise=CCMP
    wpa_passphrase=${config.sops.placeholder."router/wifiPassword"}
  '';
  sops.secrets."router/wifiPassword" = {
    sopsFile = "${config.passthru.gjz010.secretRoot}/router/router.yaml";
  };
  networking.firewall.trustedInterfaces = [ wifi ethInternal vpn-dev ];
  networking.networkmanager.unmanaged = [ wifi ethInternal vpn-dev ];
  networking.nat = {
    enable = true;
    internalInterfaces = [ wifi ethInternal vpn-dev ];
    externalInterface = eth;
    enableIPv6 = true;
  };
  nixpkgs.overlays = [
    (self: super: {
      #miniupnpd = super.miniupnpd.override {
      #  iptables = self.iptables-legacy;
      #};
    })
  ];

  #services.miniupnpd = {
  #  enable = true;
  #  externalInterface = eth;
  #  internalIPs = [wifi ethInternal vpn-dev];
  #  natpmp = true;
  #};

  #  networking.dhcpcd.denyInterfaces = [ wifi ];
  networking.interfaces."${wifi}" = {

    ipv4.addresses = [{
      address = ipAddress;
      prefixLength = prefixLength;
    }];
    ipv6.addresses = [{
      address = ip6Address;
      prefixLength = ip6PrefixLength;
    }];
  };
  networking.interfaces."${ethInternal}" = {

    ipv4.addresses = [{
      address = ipAddress1;
      prefixLength = prefixLength;
    }];
    ipv6.addresses = [{
      address = ip6Address1;
      prefixLength = ip6PrefixLength;
    }];
  };

  # forward traffic coming in trough the access point => provide internet and vpn network access
  # todo : forward to own servers
  boot.kernel.sysctl = {
    "net.ipv4.conf.${wifi}.forwarding" = true;
    "net.ipv6.conf.${wifi}.forwarding" = true;
    "net.ipv4.conf.${ethInternal}.forwarding" = true;
    "net.ipv6.conf.${ethInternal}.forwarding" = true;
    "net.ipv4.conf.${vpn-dev}.forwarding" = true;
    "net.ipv6.conf.${vpn-dev}.forwarding" = true;
  };
  systemd.services.hostapd = {
    description = "hostapd wireless AP";
    path = [ pkgs.hostapd ];
    # start manual
    wantedBy = [ "network.target" ];
    after = [
      "${wifi}-cfg.service"
      "nat.service"
      "bind.service"
      "dhcpd.service"
      "sys-subsystem-net-devices-${wifi}.device"
    ];
    serviceConfig = {
      ExecStart = "${pkgs.hostapd}/bin/hostapd ${config.sops.templates."router-hostapd.conf".path}";
      Restart = "always";
    };
  };
  services.dnsmasq = {
    enable = true;
    extraConfig = ''
      server=114.114.114.114
      no-resolv
      # Only listen to routers' LAN NIC.  Doing so opens up tcp/udp port 53 to
      # localhost and udp port 67 to world:
      interface=${wifi}
      interface=${ethInternal}
      enable-ra
      # Explicitly specify the address to listen on
      listen-address=${ipAddress}
      listen-address=${ip6Address}
      listen-address=${ipAddress1}
      listen-address=${ip6Address1}
      # Dynamic range of IPs to make available to LAN PC and the lease time.
      # Ideally set the lease time to 5m only at first to test everything works okay before you set long-lasting records.
      dhcp-range=${servedAddressRange}
      dhcp-range=${ip6ServedAddressRange}
      dhcp-range=${servedAddressRange1}
      dhcp-range=${ip6ServedAddressRange1}
      localise-queries
      interface-name=${config.networking.hostName},${wifi}
      interface-name=${config.networking.hostName},${ethInternal}
      interface-name=${config.networking.hostName},${vpn-dev}
    '';
    resolveLocalQueries = false;
  };
  networking.nameservers = ["::1"];

  networking.nftables.enable = true;
  networking.nftables.tables."nat-udp-broadcast-forward" = {
    family = "ip";
    content =
      ''
        chain prerouting {
            type filter hook prerouting priority -150; policy accept;
            ip daddr 255.255.255.255 iifname ${wifi} ip saddr 192.168.76.0/24 dup to 192.168.77.255;
            ip daddr 255.255.255.255 iifname ${ethInternal} ip saddr 192.168.77.0/24 dup to 192.168.76.255;
        }
      '';
  };
}
