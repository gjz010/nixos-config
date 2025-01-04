{
  stdenvNoCC,
  callPackage,
  mpv,
  ffmpeg-full,
  makeWrapper,
  lib,
  enableMPV ? false,
  enableFFPlay ? false,
}:
let
  node-packages = callPackage ./node-packages { };
  blivec-npm = node-packages."@hyrious/blivec";
  inherit (lib.lists) optional;
in
stdenvNoCC.mkDerivation {
  name = "blivec";
  version = "0.3.15";
  meta.mainProgram = "bl";
  buildInputs = [ blivec-npm ] ++ (optional enableMPV mpv) ++ (optional enableFFPlay ffmpeg-full);
  nativeBuildInputs = [ makeWrapper ];
  phases = [ "installPhase" ];
  installPhase =
    let
      enablePath = flag: package: if flag then "--prefix PATH : \"${package}\"/bin" else "";
    in
    ''
           mkdir -p $out/bin
           makeWrapper ${blivec-npm}/bin/bl $out/bin/bl \
               ${enablePath enableMPV mpv} \
      	    ${enablePath enableFFPlay ffmpeg-full}
    '';
}
