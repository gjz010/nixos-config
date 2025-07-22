# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  nixpkgs,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    #      "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
  ];
  services.udev.packages = [
    pkgs.android-udev-rules
  ];
  programs.adb.enable = true;
  programs.corectrl.enable = true;
  programs.nix-ld.enable = true;
  programs.ydotool = {
    enable = true;
  };
  programs.hyprland = {
    enable = true;
  };
  services.xserver.desktopManager.runXdgAutostartIfNone = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.windowManager.bspwm.enable = true;
  #services.xserver.windowManager.bspwm.configFile = ./bspwm-starter-pack/bspwm/bspwmrc;
  services.xserver.dpi = 160;
  programs.thunar.enable = true;
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
  boot.initrd.kernelModules = [
    "nfs"
    "v4l2loopback"
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  hardware.xpadneo.enable = true;
  boot.kernelModules = [ "v4l2loopback" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "amdgpu.sg_display=0"
    "amd_iommu=on"
    "vfio-pci.ids=1022:15b8"
  ];
  boot.supportedFilesystems = [ "ntfs" ];
  #hardware.firmware = [(import ./firmware/amdgpu {})];
  networking.hostName = "nixos-desktop"; # Define your hostname.
  boot.binfmt.emulatedSystems = [
    "riscv64-linux"
    "aarch64-linux"
  ];
  boot.binfmt.preferStaticEmulators = true;
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

  #services.gnome.gnome-remote-desktop.enable = true;
  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "zh_CN.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  #services.xserver.videoDrivers = ["amdgpu"];
  hardware.graphics = {
    enable = true;
    #driSupport = true;
    #driSupport32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      amdvlk
    ];
  };

  # Enable the KDE Plasma Desktop Environment.
  #services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "cn";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ gutenprint ];
  services.transmission.enable = true;
  services.transmission.openPeerPorts = true;
  # Enable sound with pipewire.
  #sound.enable = true;
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
  services.libinput.enable = true;
  #programs.bash.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraGroups.docker.members = [ "gjz010" ];
  users.users.gjz010 = {
    isNormalUser = true;
    description = "gjz010";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "docker"
      "transmission"
      "adbusers"
    ];
    packages = with pkgs; [
      #  thunderbird
    ];
    shell = pkgs.bash;
    hashedPasswordFile = config.sops.secrets."shadow/nixos-desktop/gjz010".path;
  };
  sops.secrets."shadow/nixos-desktop/gjz010" = {
    neededForUsers = true;
  };
  home-manager.users.gjz010 = import ./home.nix;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    nfs-utils
    docker-compose
    transmission_3-qt
    virt-manager
    dconf
    #virtiofsd
    firefox
    kdePackages.kate
    kdePackages.krfb
    virtiofsd
    virt-viewer
    gitFull
    git-crypt
    kitty
    kdePackages.ark
    #miraclecast
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
  services.openssh.ports = [
    2222
    22
  ];
  services.openssh.settings.X11Forwarding = true;
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    2222
    5001
    5201
    5900
    5901
    33333
    22333
    8000
    3389
    22000
    7860
    27040
    3389
  ];
  networking.firewall.allowedUDPPorts = [
    55400
    22000
    21027
    27031
    27032
    27033
    27034
    27035
    27036
    3389
  ];
  #networking.networkmanager.unmanaged = [ "wlp11s0" ];
  services.syncthing = {
    enable = true;
    user = "gjz010";
    dataDir = "/home/gjz010/link/Syncthing"; # Default folder for new synced folders
    configDir = "/home/gjz010/.config/syncthing"; # Folder for Syncthing's settings and keys
  };
  #   networking.firewall.allowedTCPPorts = [ 22000 ];
  #   networking.firewall.allowedUDPPorts = [ 22000 21027 ];
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
    settings.trusted-users = [ "gjz010" ];
    #settings.substituters =  pkgs.lib.mkForce [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];

  };
  gjz010.options.preferredDesktop.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.podman.enable = true;
  #virtualisation.lxd.enable = true;
  virtualisation.waydroid.enable = true;
  virtualisation.libvirtd.qemu.ovmf.enable = true;
  virtualisation.libvirtd.qemu.ovmf.packages = [
    pkgs.OVMFFull.fd
    pkgs.pkgsCross.aarch64-multiplatform.OVMF.fd
  ];
  virtualisation.libvirtd.qemu.swtpm.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  /*
    services.guix.enable = true;
    nixpkgs.overlays = [
      (final: prev: {
        guile-lzlib = prev.guile-lzlib.overrideAttrs (
          f2: p2: {
            patches = [
              # fix support for gcc14
              (final.fetchpatch {
                url = "https://notabug.org/guile-lzlib/guile-lzlib/commit/3fd524d1f0e0b9beeca53c514620b970a762e3da.patch";
                hash = "sha256-I1SSdygNixjx5LL/UPOgEGLILWWYKKfOGoCvXM5Sp/E=";
              })
            ];
          }
        );
      })
    ];
  */

  programs.appimage.enable = true;
  programs.appimage.binfmt = true;
  programs.fish.enable = true;
  services.ollama = {
    enable = true;
    models = "/mnt/zhitai-data/ollama-models";
    acceleration = "rocm";
    rocmOverrideGfx = "11.0.0";
    host = "0.0.0.0";
    openFirewall = true;
    environmentVariables = {
      OLLAMA_ORIGINS = "*";
      #OLLAMA_CONTEXT_LENGTH = "131072";
    };
  };
  services.nextjs-ollama-llm-ui = {
    enable = true;
  };
  services.owncast = {
    port = 7860;
    listen = "0.0.0.0";
    openFirewall = false;
    enable = false;
  };
  /*
    services.open-webui = {
    enable = true;
    port = 8889;
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      ENABLE_OPENAI_API = "False";
      HTTP_PROXY = "http://192.168.76.1:30086";
      HTTPS_PROXY = "http://192.168.76.1:30086";
      http_proxy = "http://192.168.76.1:30086";
      https_proxy = "http://192.168.76.1:30086";
    };

    };
  */

  #networking.interfaces.enp10s0.wakeOnLan.enable = true;
  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.ensureProfiles.profiles = import ./nm.nix;

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
