{
  fileSystems."/mnt/samsung" = {
    device = "/dev/disk/by-uuid/5c2a4fe1-b043-4535-9388-55331d618627";
    fsType = "btrfs";
    options = [
      "compress=zstd"
    ];
  };
  fileSystems."/mnt/samsung-data" = {
    device = "/dev/disk/by-uuid/5c2a4fe1-b043-4535-9388-55331d618627";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "subvol=data"
    ];
  };
  #boot.supportedFilesystems = [ "ntfs" ];
}
