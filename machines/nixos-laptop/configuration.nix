# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, ... }:
{

  boot.kernelParams = [
    "hid_apple.fnmode=2"
  ];
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
    options kvm_intel nested=1
  '';
  boot.kernelModules = [ "hid-apple" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  services.udev.packages = [
    pkgs.android-udev-rules
  ];

  programs.dconf.enable = true;

  nix.settings.substituters = [ "https://mirrors.cernet.edu.cn/nix-channels/store" ];
  nix.settings.trusted-users = [ "gjz010" ];

  imports =
    [
      ./hardware-configuration.nix
      ./nix-direnv.nix
      ./samba-win10.nix
    ];
  home-manager.useGlobalPkgs = true;
  virtualisation.spiceUSBRedirection.enable = true;
  #virtualisation.podman = {
  #  enable = true;
  # Required for containers under podman-compose to be able to talk to each other.
  #defaultNetwork.dnsname.enable = true;
  #};
  nixpkgs.config.allowUnfree = true;
  #hardware.tuxedo-keyboard.enable = true;
  #hardware.tuxedo-control-center.enable = true;
  hardware.tuxedo-rs.enable = true;
  hardware.tuxedo-rs.tailor-gui.enable = true;
  hardware.bluetooth.enable = true;
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;
  boot.supportedFilesystems = [ "ntfs" ];
  programs.steam.enable = true;
  programs.kdeconnect.enable = true;
  hardware.opengl.enable = true;

  hardware.nvidia =
    {
      powerManagement.enable = true;
      nvidiaSettings = true;
      modesetting.enable = true;
      nvidiaPersistenced = true;
    };

  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp110s0.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "zh_CN.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.smartd.enable = true;
  # Enable the GNOME Desktop Environment.
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;
  #services.xserver.displayManager.gdm.wayland = true;
  #services.xserver.displayManager.gdm.nvidiaWayland = true;
  #services.xserver.displayManager.lightdm.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  #services.xrdp.enable=true;
  #services.xrdp.defaultWindowManager = "startplasma-x11";
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-rime fcitx5-chinese-addons ];
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
  ];

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  #security.wrappers.spice-client-glib-usb-acl-helper.source = "${pkgs.spice_gtk}/bin/spice-client-glib-usb-acl-helper.real";

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.gjz010 = {
    isNormalUser = true;
    home = "/home/gjz010";
    extraGroups = [ "wheel" "docker" "libvirtd" "vboxusers" "networkmanager" ]; # Enable ‘sudo’ for the user.
    hashedPasswordFile = config.sops.secrets."shadow/nixos-laptop/gjz010".path;
  };
  home-manager.users.gjz010 = import ./home.nix;
  sops.secrets."shadow/nixos-laptop/gjz010" = {
    neededForUsers = true;
  };
  # services.softether.enable = true;
  # services.softether.vpnclient.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    helvum
    alsa-oss
    firefox
    #v2ray
    vscodium
    libguestfs
    gsmartcontrol
    #wineWowPackages.stable
    #winetricks
    spice-gtk
    tigervnc
    virtualgl
    virtualglLib
    kmail
    git
    virt-manager
    remmina
  ];
  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.docker.enableNvidia = true;
  services.softether = {
    enable = true;
    vpnclient.enable = true;
  };
  services.printing.enable = true;


  #fileSystems."/export/gjz010" = {
  #  device = "/home/gjz010";
  #  options = ["bind"];
  #};
  #services.nfs.server.enable = true;
  #services.nfs.server.exports = ''
  #  /export 192.168.77.95(rw,insecure,no_subtree_check)
  #  /export/gjz010 192.168.77.95(rw,insecure,no_subtree_check)
  #'';
  #systemd.services.mount-vm-disk= {
  #  wantedBy = [ "multi-user.target" ];
  #  path = [ pkgs.qemu pkgs.kmod pkgs.mount pkgs.umount ];
  #  serviceConfig.Type = "oneshot";
  #  serviceConfig.RemainAfterExit = true;
  #  script = ''
  #    modprobe nbd max_part=16
  #    qemu-nbd -c /dev/nbd0 /mnt/win10/games.qcow2
  #    mkdir -p /mnt/games
  #    mount /dev/nbd0p1 /mnt/games -o defaults,
  #  '';
  #  preStop = ''
  #    umount -f /mnt/games
  #    qemu-nbd -d /dev/nbd0
  #    rmmod nbd
  #  '';
  #};
  /*
    systemd.services.x11vnc = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "display-manager.service" ];
    path = [pkgs.x11vnc pkgs.gawk pkgs.nettools pkgs.xorg.xauth];
    serviceConfig = {
      ExecStart = "${pkgs.x11vnc}/bin/x11vnc -auth guess -forever -loop -repeat -rfbauth /etc/x11vnc.passwd -rfbport 5900 -shared -display :0";
      #Restart="on-failure";
      #RestartSec=3;
    };
    };
  */
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.ports = [ 22 2222 ];
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 2222 22333 ];
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --source 192.168.122.0/24 --dport 445 -j nixos-fw-accept
    iptables -A nixos-fw --source 192.168.76.0/24 -j nixos-fw-accept
    iptables -A nixos-fw --source 192.168.77.0/24 -j nixos-fw-accept
    iptables -A nixos-fw --source 192.168.78.0/24 -j nixos-fw-accept
  '';
  networking.firewall.trustedInterfaces = [ "enp0s20f0u4c2" "virbr0" ];
  # gjz010.services.nixos-cache-local.enable = true;

  boot.tmp.useTmpfs = true;
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  environment.sessionVariables = {
    NIX_PROFILES =
      "${builtins.concatStringsSep " " (pkgs.lib.reverseList config.environment.profiles)}";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

