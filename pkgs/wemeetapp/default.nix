{ stdenv
, lib
, dpkg
, fetchurl
, buildFHSUserEnv
, autoPatchelfHook
, libsForQt515
, librsvg
}:
let
  libsForQt5 = libsForQt515;
  wemeet = stdenv.mkDerivation {
    pname = "wemeetapp";
    version = "3.19.0.401";
    deb = fetchurl {
      url = "https://updatecdn.meeting.qq.com/cos/bb4001c715553579a8b3e496233331d4/TencentMeeting_0300000000_3.19.0.401_x86_64_default.publish.deb";
      sha256 = "07rgvmmwn74ds8d54c3bd03mfpq676a2xcqlx1jns0xkglvfppsl";
      meta.license = lib.licenses.unfree;
    };
    buildInputs = with libsForQt5.qt5; [
      qtlocation
      qtwebengine
      qtwebchannel
      qtx11extras
    ];
    nativeBuildInputs = [ autoPatchelfHook libsForQt5.wrapQtAppsHook dpkg librsvg ];
    phases = [ "unpackPhase" "installPhase" "fixupPhase" ];
    unpackPhase = ''
      echo "  -> Extracting the deb package..."
      dpkg -x $deb ./deb
    '';
    wemeetLibrary = [
      "libdesktop_common.so"
      "libwemeet.so"
      "libwemeet_base.so"
      "libwemeet_framework.so"
      "libui_framework.so"
      "libwemeet_util.so"
      "libnxui_uikit.so"
      "libqt_framework.so"
      "libqt_util.so"
      "libqt_ui_framework.so"
      "libqt_uikit.so"
      "libwemeet_module_api.so"
      "libwemeet_sdk.so"
      "libservice_manager.so"
      "libwemeet_qt.so"
      "libwemeet_app_components.so"
      "libwemeet_app_sdk.so"
      "libxnn.so"
      "libxnn_core.so"
      "libxcast.so"
      "libxcast_codec.so"
      "libImSDK.so"
      "libwemeet_plugins.so"
      "libxnn_media.so"
      "libnxui_app.so"
      "libnxui_component.so"
      "libwemeet_migration.so"
    ];
    dontWrapQtApps = true;
    installPhase = ''
      echo $foo
      mkdir -p $out/bin $out/lib
      cp -r ./deb/opt/wemeet/bin $out
      rm $out/bin/QtWebEngineProcess
      ln -s ${libsForQt5.qt5.qtwebengine.out}/libexec/QtWebEngineProcess $out/bin
      for lib in $wemeetLibrary; do
          cp ./deb/opt/wemeet/lib/$lib $out/lib
      done
      cp -r ./deb/opt/wemeet/{resources,translations} $out
      mkdir -p $out/share $out/share/applications
      cp -r ./deb/opt/wemeet/icons $out/share
      cp ${./wemeetapp.desktop} $out/share/applications/wemeetapp.desktop
      for size in 16 32 64 128 256; do
        icon_path=$out/share/icons/hicolor/''${size}x''${size}
        mkdir -p $icon_path
        rsvg-convert -w $size -h $size ./deb/opt/wemeet/wemeet.svg -o $icon_path/wemeetapp.png
      done
    '';
    postFixup = ''
      wrapQtApp "$out/bin/wemeetapp" --prefix PATH : $out/bin
    '';
  };
in
wemeet
