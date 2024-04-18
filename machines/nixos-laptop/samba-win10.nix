{
  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      wins support = yes
      server string = smbnix
      netbios name = smbnix
      security = user 
      #use sendfile = yes
      #max protocol = smb2
      hosts allow = 192.168.122.48, 127.0.0.1, 192.168.122.1 192.168.122.0/24 192.168.76.0/24 192.168.77.0/24 192.168.78.0/24
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
    '';
    shares = {
      win10 = {
        path = "/home/gjz010/link";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "valid users" = "gjz010";
      };
    };
  };
}
