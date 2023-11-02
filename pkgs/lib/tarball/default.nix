{pkgs}:
with pkgs;
{ name, drv, entry, tarballPrefix? name}:
let
    inherit (gjz010.pkgs) nix-user-chroot;
    drv_path = (builtins.toString drv);
    maketar = { targets }:
        let
            entryScriptPath = writeScript "${name}-entry" ''
                #!/bin/sh
                NIX_CHROOT_PATH=$(dirname "$0")
                exec $NIX_CHROOT_PATH/${nix-user-chroot}/bin/nix-user-chroot $NIX_CHROOT_PATH/nix ${entry} "$@"
            '';
        in
        stdenvNoCC.mkDerivation {
            name = "${tarballPrefix}-tarball.tar.gz";
            buildInputs = [ perl ];
            exportReferencesGraph = map (x: [ ("closure-" + baseNameOf x) x ]) targets;
            buildCommand = ''
                storePaths=$(perl ${pathsFromGraph} ./closure-*)
                cp ${entryScriptPath} /build/${name}
                chmod +x /build/${name}
                echo $storePaths
                tar -cvf - \
                    --owner=0 --group=0 --mode=u+rw,uga+r \
                    --hard-dereference \
                    $storePaths > /build/temp.tar
                tar -C /build -rf /build/temp.tar ${name}
                cat /build/temp.tar | gzip -9 > $out
            '';
        };
in
maketar { targets = [ drv nix-user-chroot ]; }
