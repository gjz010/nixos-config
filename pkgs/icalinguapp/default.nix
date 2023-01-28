{ electron, pkgs, stdenv }:
with pkgs;
stdenv.mkDerivation {
  pname = "icalinguapp";
  version = "2.8.6";
  #builder = ./builder.sh;
  src = ./.;
  asar = fetchurl {
    url = "https://github.com/Icalingua-plus-plus/Icalingua-plus-plus/releases/download/v2.8.6/app-x86_64.asar";
    sha256 = "1dg9ss4bjnrg85ga8mz7apqy4jblbmwns4rjgz1q6lfaf6cmzk9s";
  };
  buildInputs = [ electron ];
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/lib/icalinguapp
    cp $asar $out/lib/icalinguapp/app.asar
    mkdir -p $out/bin
    echo '#!/bin/sh' > $out/bin/icalinguapp
    echo '${electron}/bin/electron' $out/lib/icalinguapp/app.asar >> $out/bin/icalinguapp
    chmod +x $out/bin/icalinguapp
    cp -r $src/share $out/
  '';
}
