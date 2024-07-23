flake@{ inputs, self }:
{ config, lib, pkgs, ... }: {
  options.gjz010.drivers.nvk = {
    enable = lib.mkEnableOption "Enable NVK.";
  };
  options.gjz010.drivers.nvidia-proprietary = {
    enable = lib.mkEnableOption "Enable Proprietary Nvidia Driver.";
    driverPkg = lib.mkOption {
      default = config.boot.kernelPackages.nvidiaPackages.beta;
      description = "Nvidia proprietary driver version.";
      type = lib.types.package;
    };
    # https://github.com/NixOS/nixpkgs/issues/254614
    openKernelDriver = lib.mkEnableOption "Use open kernel driver.";
  };

  config = lib.mkMerge [
    (lib.mkIf config.gjz010.drivers.nvk.enable {
      boot.kernelParams = [
        "nouveau.config=NvGspRM=1"
        "nouveau.debug=info,VBIOS=info,gsp=debug"
      ];
      services.xserver.videoDrivers = [ "modesetting" ];
    })
    (lib.mkIf config.gjz010.drivers.nvidia-proprietary.enable {
      services.xserver.videoDrivers = [ "nvidia" ];
      boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];
      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        open = config.gjz010.drivers.nvidia-proprietary.openKernelDriver;
        nvidiaPersistenced = true;
        nvidiaSettings = true;
        package = config.gjz010.drivers.nvidia-proprietary.driverPkg;
      };
      hardware.opengl.driSupport = false;
      hardware.opengl.package = config.gjz010.drivers.nvidia-proprietary.driverPkg;
    })
  ];
}
