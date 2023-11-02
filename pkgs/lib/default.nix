{pkgs}:
rec {
    tarball = import ./tarball {inherit pkgs;};
    tarballBundler = drv: 
        let program = p: pkgs.lib.getExe p;
        in tarball {
            name = (builtins.parseDrvName drv.name).name;
            drv = drv;
            entry = (program drv);
            tarballPrefix = drv.name;
        };
}
