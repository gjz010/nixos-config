default:
    just --list
updatekeys:
    find secrets -type f -exec sops updatekeys -y {} \;
autocommit:
    git add .
    git commit -m "Autocommit from `hostname` on `date`"
nebula-rotate-cert:
    RUST_LOG=info nix run .#gjz010-nebula-manager rotate-cert ./secrets/nebula/network.yaml ./secrets/nebula/certs
nebula-export-json:
    RUST_LOG=info nix run .#gjz010-nebula-manager export-json ./secrets/nebula/network.yaml ./modules/nebula/network.json