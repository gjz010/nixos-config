{ gjz010Flake }:
final: prev:
let
  packages = {
    icalinguapp = final.callPackage ./pkgs/icalinguapp { };
    hmcl = final.callPackage ./pkgs/hmcl { };
    blivec = final.callPackage ./pkgs/blivec { enableFFPlay = true; };
    blivec-mpv = final.callPackage ./pkgs/blivec { enableMPV = true; };
    wechat-uos = final.callPackage ./pkgs/wechat-uos { };
    wemeetapp = final.callPackage ./pkgs/wemeetapp { };
    nix-user-chroot = final.callPackage ./pkgs/nix-user-chroot { };
    proxychains-wrapper = final.callPackage ./pkgs/proxychains-wrapper { };
    python3WithLD = final.callPackage ./pkgs/python3WithLD { };
    nixos-with-flake-init = final.callPackage ./pkgs/nixos-with-flake-init { inherit gjz010Flake; };
    kcptun-bin = final.callPackage ./pkgs/kcptun-bin { };
    goauthing = final.callPackage ./pkgs/goauthing { };
    electron_33-bin = final.callPackage ./pkgs/electron_33-bin { };
    phantun = final.callPackage ./pkgs/phantun { };
    yesplaymusic-osd = final.callPackage ./pkgs/yesplaymusic-osd { };
    gjz010-nebula-manager = final.callPackage ./pkgs/gjz010-nebula-manager { };
    transmission-4-1 = final.callPackage ./pkgs/transmission-4-1 {
      fmt = final.fmt_9;
      libutp = final.libutp_3_4;
    };
    transmission-4-0-5 = final.callPackage ./pkgs/transmission-4-0-5 {
      fmt = final.fmt_9;
      libutp = final.libutp_3_4;
    };
    botamusique = final.callPackage ./pkgs/botamusique { };
  };
  examples = {
    egui-test = final.callPackage ./pkgs/examples/egui-test { };
    completion-test = final.callPackage ./pkgs/examples/completion-test { };
  };
  linuxPackages = (
    self: super: {
      tuxedo-drivers =
        if final.lib.versionAtLeast self.kernel.version "6.7" then
          self.callPackage ./pkgs/kernel/tuxedo-drivers { }
        else
          null;
      tuxedo-keyboard = null;
    }
  );
in
{
  gjz010 = {
    pkgs = packages // {
      inherit examples;
    };
    inherit packages;
    lib = final.callPackage ./pkgs/lib { };
    bundlers = {
      toTarball = final.gjz010.lib.tarballBundler;
    };
  };
  linuxPackages_latest = prev.linuxPackages_latest.extend linuxPackages;
}
