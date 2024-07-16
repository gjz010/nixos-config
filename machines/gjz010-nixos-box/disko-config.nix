{
    disko.devices = {
        disk = {
            nvme0n1 = {
                device = "/dev/disk/by-id/nvme-ZHITAI_Ti600_1TB_ZTA601TAB24022FTJV";
                type = "disk";
                content = { 
                    type = "gpt";
                    partitions = { 
                        ESP = { 
                            type = "EF00";
                            size = "512M";
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
                                    "/home/gjz010" = {};
                                    "/nix" = {
                                        mountOptions = [ "compress=zstd" "noatime" ];
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
