{pkgs}:
with pkgs;
let
maketar =  targets :
    stdenv.mkDerivation {
      name = "maketar";
      buildInputs = [ perl ];
      exportReferencesGraph = map (x: [("closure-" + baseNameOf x) x]) targets;
      buildCommand = ''
        storePaths=$(perl ${pathsFromGraph} ./closure-*)
        tar -cf - \
          --owner=0 --group=0 --mode=u+rw,uga+r \
          --hard-dereference \
          $storePaths > /build/temp.tar
        cat /build/temp.tar | gzip -9 > $out
      '';
    };
in 
maketar
