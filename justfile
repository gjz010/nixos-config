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
nebula-show-config hostname:
    RUST_LOG=info nix run .#gjz010-nebula-manager merge-config \
    ./secrets/nebula/network.yaml \
    <(sops -d secrets/nebula/network_secrets.yaml.enc) \
    {{hostname}} \
    PLACEHOLDER \
    PLACEHOLDER \
    PLACEHOLDER \
    /dev/stdout \
    | yq ".pki.ca = load_str(\""<(sops -d secrets/nebula/certs/ca.crt)"\")" /dev/stdin \
    | yq ".pki.cert = load_str(\""<(sops -d secrets/nebula/certs/certs/{{hostname}}.crt)"\")" /dev/stdin \
    | yq ".pki.key = load_str(\""<(sops -d secrets/nebula/certs/keys/{{hostname}}.key)"\")" /dev/stdin
