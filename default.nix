{pkgs? import <nixpkgs> {} } :
{
    icalinguapp = pkgs.callPackage ./pkgs/icalinguapp {};
}

