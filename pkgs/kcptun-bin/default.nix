{ autoPatchelfHook, stdenvNoCC, lib, unar}:
let
inherit (builtins) fetchurl;
kcptunBinaries = {
  "x86_64-linux" = rec {
    version = "20240107";
    release = fetchurl {
      url = "https://github.com/xtaci/kcptun/releases/download/v${version}/kcptun-linux-amd64-${version}.tar.gz";
      sha256 = "06mvky1a3is7fgh2q9fi8l4g17v02j54grm8zm3fms6h9xncw4ak";
    };
    client = "client_linux_amd64";
    server = "server_linux_amd64";
  };
  "aarch64-linux" = rec {
    version = "20240107";
    release = fetchurl {
      url = "https://github.com/xtaci/kcptun/releases/download/v${version}/kcptun-linux-arm64-${version}.tar.gz";
      sha256 = "137rsciif2vqix53bmxq1b67rn6bw2a1h7wvq8fl93hshdckp9rv";
    };
    client = "client_linux_arm64";
    server = "server_linux_arm64";
  };
};
kcptunBinary = kcptunBinaries."${stdenvNoCC.hostPlatform.system}" or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "kcptun-bin";
  version = kcptunBinary.version;

  nativeBuildInputs = [ unar ];

  unpackPhase = ''
    mkdir -p $TMP/kcptun
    cd $TMP/kcptun
    unar -D ${kcptunBinary.release}
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp -r $TMP/kcptun/${kcptunBinary.client} $out/bin/kcptun-client
    cp -r $TMP/kcptun/${kcptunBinary.server} $out/bin/kcptun-server
    chmod +x $out/bin/kcptun-*
  '';


  meta = with lib; {
    description = "A Stable & Secure Tunnel Based On KCP with N:M Multiplexing & FEC";
    homepage = "https://github.com/xtaci/kcptun";
    license = licenses.mit;
  };
}
