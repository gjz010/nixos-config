{
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
}:
rustPlatform.buildRustPackage rec {
  pname = "phantun";
  version = "495bad10268de901759f3d763b878af8c236c82f";
  nativeBuildInputs = [ makeWrapper ];
  src = fetchFromGitHub {
    owner = "gjz010-Forks";
    repo = pname;
    rev = version;
    hash = "sha256-ENFx4ZkaFxiN9cKfdWk2x1CWgnMysbgan7bjhpiRUEg=";
  };
  cargoHash = "sha256-QV1rdhztXqTGuiT2ybxLAYJxi4/G9voFVHkCkPpwaKM=";
  postFixup = ''
    mv $out/bin/client $out/bin/phantun-client
    mv $out/bin/server $out/bin/phantun-server
  '';
}
