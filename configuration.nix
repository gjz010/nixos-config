# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, nixpkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./cachix.nix
#      "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
    ];
  services.udev.packages = [
    pkgs.android-udev-rules
  ];
  services.udev.extraRules = ''
    KERNEL=="kvm", NAME="i_love_kernel_virtualization"    
  '';
  programs.adb.enable = true;
  programs.corectrl.enable = true;
  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiInstallAsRemovable = true;
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub.memtest86.enable = true;
  boot.loader.grub.extraEntries = ''
    menuentry "Memtest86+ bootPath" {
      linux @bootRoot@/efi/memtest.bin 
    }
  '';
  boot.tmp.useTmpfs = false;
  boot.initrd.kernelModules = [ "nfs" "v4l2loopback" "vfio_pci" "vfio" "vfio_iommu_type1" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "amdgpu.sg_display=0" "amd_iommu=on" "vfio-pci.ids=1022:15b8" ];
  boot.supportedFilesystems = [ "ntfs" ];
  #hardware.firmware = [(import ./firmware/amdgpu {})];
  networking.hostName = "nixos-desktop"; # Define your hostname.
  boot.binfmt.emulatedSystems = [ "riscv64-linux" "aarch64-linux" ];
  hardware.bluetooth.enable = true;
#  virtualisation.memorySize = 8192;
#  virtualisation.cores = 8;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  boot.kernel.sysctl = {
    "net.bridge.bridge-nf-call-ip6tables" = 0;
    "net.bridge.bridge-nf-call-iptables" = 0;
    "net.bridge.bridge-nf-call-arptables" = 0;
  };
  # Enable networking
  networking.networkmanager.enable = true;
  #services.gnome.gnome-remote-desktop.enable = true;
  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "zh_CN.utf8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  #services.xserver.videoDrivers = ["amdgpu"];
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
  };



  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma6.enable = true;
  # Configure keymap in X11
  services.xserver = {
    layout = "cn";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.transmission.enable = true;
  services.transmission.openPeerPorts = true;
  # Enable sound with pipewire.
  sound.enable = true;
  #hardware.pulseaudio.enable = true;
  #hardware.pulseaudio.support32Bit = true;
  #nixpkgs.config.pulseaudio = true;
  programs.dconf.enable = true;
  security.rtkit.enable = true;
  services.flatpak.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

#  virtualisation.qemu.options = [
#    "-vga none"
#    "-device virtio-gpu-gl-pci"
#    "-display gtk,gl=on"
#  ];


  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  #programs.bash.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraGroups.docker.members = [ "gjz010" ];
  users.users.gjz010 = {
    isNormalUser = true;
    description = "gjz010";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "docker" "transmission" "adbusers" ];
    packages = with pkgs; [
      #  thunderbird
    ];
    hashedPassword = "REDACTED";
    shell = pkgs.bash;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    nfs-utils
    docker-compose
    transmission-qt
    virt-manager
    dconf
    #virtiofsd
    firefox
    kate
    kdePackages.krfb
    virtiofsd
    virt-viewer
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.steam.enable = true;
  programs.kdeconnect.enable = true;
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.ports = [ 2222 22 ];
  services.openssh.settings.X11Forwarding = true;
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 2222 5001 5201 5900 5901 33333 22333 8000 3389 ];
  #networking.bridges = {
  #  "br0" = {
  #    interfaces = [ "enp10s0" ];
  #  };
  #};
  #networking.interfaces.br0.useDHCP = true;
  #networking.interfaces.enp10s0.useDHCP = true;
  #networking.dhcpcd.denyInterfaces = [ "macvtap0@*" ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  nix = {
    #package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings.trusted-users = ["gjz010"];
    #settings.substituters =  pkgs.lib.mkForce [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];

  };
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-rime fcitx5-chinese-addons fcitx5-configtool ];
  };
  fonts.packages = with pkgs; [
    wqy_zenhei
    wqy_microhei
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    sarasa-gothic
    jetbrains-mono
  ];
  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.podman.enable = true;
  #virtualisation.lxd.enable = true;
  virtualisation.waydroid.enable = true;
  virtualisation.libvirtd.qemu.ovmf.enable = true;
  virtualisation.libvirtd.qemu.ovmf.packages = [ pkgs.OVMFFull.fd ];
  virtualisation.libvirtd.qemu.swtpm.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  #  environment.sessionVariables = {
  #      GTK_IM_MODULE = "fcitx";
  #      QT_IM_MODULE = "fcitx";
  #      XMODIFIERS = "@im=fcitx";
  #  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
