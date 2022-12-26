My Nix channel
==============


```
nix-channel --add https://github.com/gjz010/nix-channel/archive/refs/heads/main.tar.gz gjz010
nix-channel --update gjz010
```

Use packages
--------------

```
let gjz010 = import <gjz010> {}; in gjz010.icalinguapp
```



Make tar closure
-------------
```
nix-build -E "let pkgs = import <nixpkgs> {}; packClosure = (import <gjz010> {}).lib.packClosure; in packClosure [pkgs.gcc]"
```
