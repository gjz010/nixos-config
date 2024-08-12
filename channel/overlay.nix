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
  };
  examples = {
    egui-test = final.callPackage ./pkgs/examples/egui-test { };
    completion-test = final.callPackage ./pkgs/examples/completion-test { };
  };
in
{
  gjz010 = {
    pkgs = packages // { inherit examples; };
    lib = final.callPackage ./pkgs/lib { };
  };
}
