{pkgs}:
rec {
    tarball = import ./tarball {inherit pkgs;};
    tarballBundler = drv: 
        let program = p: "${p}/bin/${
            if p?meta && p.meta?mainProgram then
            p.meta.mainProgram
            else (builtins.parseDrvName (builtins.unsafeDiscardStringContext p.name)).name
        }";
        in tarball {
            name = (builtins.parseDrvName drv.name).name;
            drv = drv;
            entry = (program drv);
            tarballPrefix = drv.name;
        };
}
