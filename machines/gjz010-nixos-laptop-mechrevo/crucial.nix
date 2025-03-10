{
  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/11B1CFE80C3B9EF3";
    fsType = "ntfs";
    options = [
      # If you don't have this options attribute, it'll default to "defaults"
      # boot options for fstab. Search up fstab mount options you can use
      "users" # Allows any user to mount and unmount
      "nofail" # Prevent system from failing if this drive doesn't mount
    ];
  };
  #
  fileSystems."/mnt/windows" = {
    device = "/dev/disk/by-uuid/44A24F06A24EFBC4";
    fsType = "ntfs";
    options = [
      # If you don't have this options attribute, it'll default to "defaults"
      # boot options for fstab. Search up fstab mount options you can use
      "users" # Allows any user to mount and unmount
      "nofail" # Prevent system from failing if this drive doesn't mount
    ];
  };
  boot.supportedFilesystems = [ "ntfs" ];
}
