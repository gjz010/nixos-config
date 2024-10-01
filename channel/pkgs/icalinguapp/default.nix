{ electron? pkgs.gjz010.pkgs.electron_33-bin, pkgs, stdenv, makeWrapper, bash }:
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
  nativeBuildInputs = [makeWrapper];
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/lib/icalinguapp
    cp $asar $out/lib/icalinguapp/app.asar
    mkdir -p $out/bin
    echo '#!${bash}/bin/bash' > $out/bin/icalinguapp
    echo "exec -a \"\$0\" ${electron}/bin/electron $out/lib/icalinguapp/app.asar \"\$@\""  >> $out/bin/icalinguapp
    chmod +x $out/bin/icalinguapp
    wrapProgram $out/bin/icalinguapp --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime  --wayland-text-input-version=3}}"
    cp -r $src/share $out/
  '';
}
