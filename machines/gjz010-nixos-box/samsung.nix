{
  fileSystems."/mnt/samsung" = {
    device = "/dev/disk/by-uuid/D0507C30507C2000";
    fsType = "ntfs";
    options = [ # If you don't have this options attribute, it'll default to "defaults" 
      # boot options for fstab. Search up fstab mount options you can use
      "users" # Allows any user to mount and unmount
      "nofail" # Prevent system from failing if this drive doesn't mount
      
    ];
  };
  boot.supportedFilesystems = ["nfts"];
}
