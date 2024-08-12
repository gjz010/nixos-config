{ mkShell
, python3
, bashInteractive
, stdenv
, zlib
, glib
, libGLU
, libGL
, unzip
, gperf
, m4
, util-linux
, gnumake
, procps
, curl
, autoconf
, gnupg
, gitRepo
, binutils
, ncurses5
, git
, lib
}:
mkShell rec{
  buildInputs = [
    python3
    bashInteractive
    stdenv.cc.cc.lib
    stdenv.cc
    zlib
    curl
    glib
    libGLU
    libGL
    unzip
    gperf
    m4
    util-linux
    gnumake
    procps
    autoconf
    gnupg
    gitRepo
    binutils
    ncurses5
    git
  ];
  LD_LIBRARY_PATH = (lib.makeLibraryPath buildInputs);
}
