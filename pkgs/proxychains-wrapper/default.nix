{ proxychains, stdenvNoCC, makeWrapper }:
stdenvNoCC.mkDerivation {
  name = "proxychains-wrapper";
  nativeBuildInputs = [ makeWrapper ];
  phases = [ "postFixup" ];
  postFixup = ''
    makeWrapper ${proxychains}/bin/proxychains4 $out/bin/proxychains4 --add-flags "-f /etc/proxychains.conf"
  '';
}
