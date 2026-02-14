{
  stdenvNoCC,
  udevCheckHook,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "canokey-udev-rules";
  version = "0.0.1";

  nativeBuildInputs = [
    udevCheckHook
  ];

  doInstallCheck = true;

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p "$out/etc/udev/rules.d/";
    cp ${./69-canokeys.rules} "$out/etc/udev/rules.d/69-canokeys.rules"
  '';

})
