{yesplaymusic, fetchurl}:
(yesplaymusic.overrideAttrs (final: prev: {
  src = fetchurl {
    url = "https://github.com/shih-liang/YesPlayMusicOSD/releases/download/v0.4.5/yesplaymusic_0.4.5_amd64.deb";
    sha256 = "04yab3122wi5vxv4i0ygas4pf50rvqz4s1khkz2hlnhj5j2p2k8h";
  };
  version = "0.4.5";
}))

