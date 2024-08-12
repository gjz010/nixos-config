{ electron, pkgs, stdenv }:
with pkgs;
stdenv.mkDerivation rec {
  pname = "icalinguapp";
  version = "2.11.0";
  #builder = ./builder.sh;
  src = ./.;
  asar = fetchurl {
    url = "https://github.com/Icalingua-plus-plus/Icalingua-plus-plus/releases/download/v${version}/app-x86_64.asar";
    sha256 = "uhKcrd5rHEN1gXVY6hYbpmteQE5ySW7bZKnsZfx3y/4=";
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
