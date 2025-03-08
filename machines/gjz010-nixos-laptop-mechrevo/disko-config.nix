{
  disko.devices = {
    disk = {
      nvme0n1 = {
        device = "/dev/disk/by-id/nvme-ZHITAI_TiPro7000_2TB_ZTA22T0KA23383040R";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "1G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              end = "-64G";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "/rootfs" = {
                    mountpoint = "/";
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" ];
                  };
                  "/home/gjz010" = { };
                  "/nix" = {
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                    mountpoint = "/nix";
                  };
                };
                mountpoint = "/partition-root";
              };
            };
            swap = {
              size = "100%";
              content = {
                type = "swap";
                resumeDevice = true;
              };
            };
          };
        };
      };
    };
  };
}
