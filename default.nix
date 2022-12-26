{pkgs? import <nixpkgs> {} } :
{
    icalinguapp = pkgs.callPackage ./pkgs/icalinguapp {};
    lib = pkgs.callPackage ./pkgs/lib {};
}

