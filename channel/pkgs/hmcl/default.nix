{
  lib,
  stdenv,
  fetchurl,
  gobject-introspection,
  gsettings-desktop-schemas,
  hicolor-icon-theme,
  dbus,
  glib,
  dconf,
  openjdk17,
  pkgs,
}:
stdenv.mkDerivation {
  pname = "hmcl";
  version = "3.5.3.230";
  src = fetchurl {
    url = "https://github.com/huanghongxun/HMCL/releases/download/v3.5.3.230/HMCL-3.5.3.230.jar";
    sha256 = "EbI+LaEGIv6BxtwrRkABY/zRmt6YOC7NFh0vPvOAuOY=";
  };
  unpackPhase = "true";
  buildInputs = with pkgs; [
    gtk2
    glib
    gsettings-desktop-schemas
    hicolor-icon-theme
    openjdk17
    wrapGAppsHook
  ];
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib/hmcl
    cp $src $out/lib/hmcl/hmcl.jar
    echo "#!/usr/bin/env bash" >$out/bin/hmcl
    echo "${pkgs.openjdk17}/bin/java -jar $out/lib/hmcl/hmcl.jar" >> $out/bin/hmcl
    chmod +x $out/bin/hmcl
  '';
}
