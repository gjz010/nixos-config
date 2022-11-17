{ electron, pkgs, stdenv }:
with pkgs;
stdenv.mkDerivation {
  pname = "icalinguapp";
  version = "2.7.7";
  #builder = ./builder.sh;
  src = ./.;
  asar = fetchurl {
    url = "https://github.com/Icalingua-plus-plus/Icalingua-plus-plus/releases/download/v2.7.7/app-x86_64.asar";
    sha256 = "19j7izpq3khxa6qn15a0jknavzf6f7xmq7pk12jicls4y93whkf8";
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
