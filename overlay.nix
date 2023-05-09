final: prev:
let packages = {
    icalinguapp = final.callPackage ./pkgs/icalinguapp {};
    hmcl = final.callPackage ./pkgs/hmcl {};
    wechat-uos = final.callPackage ./pkgs/wechat-uos {};
    wemeetapp = final.callPackage ./pkgs/wemeetapp {};
    nix-user-chroot = final.callPackage ./pkgs/nix-user-chroot {};
};
examples = {
    egui-test = final.callPackage ./pkgs/examples/egui-test {};
};
in {
    gjz010 = {
      pkgs = packages // examples;
      lib = final.callPackage ./pkgs/lib {};
    };
}
