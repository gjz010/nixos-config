My Nix channel
==============


```
nix-channel --add https://github.com/gjz010/nix-channel/archive/refs/heads/main.tar.gz gjz010
nix-channel --update gjz010
```

```
let gjz010 = import <gjz010> {}; in gjz010.icalinguapp
```
