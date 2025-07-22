default:
    just --list
updatekeys:
    find secrets -type f -exec sops updatekeys -y {} \;
autocommit reason="":
    git add .
    reason="{{reason}}"; \
    if [ -n "$reason" ]; then \
    reason=": $reason"; \
    fi; \
    git commit -m "Autocommit from `hostname` on `date`$reason"
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

tmpdir := `mktemp -d`
NIX_INJECT_FLAKE_INPUT_GIT_REV_FILE := tmpdir / ".gitrev"
NIX_INJECT_FLAKE_INPUT_FLAGS := "--override-input secretsEmbedded path:" + justfile_directory() + "/.secrets-embedded --override-input gitRevision path:" + NIX_INJECT_FLAKE_INPUT_GIT_REV_FILE


update-git-rev:
    git rev-parse HEAD > {{NIX_INJECT_FLAKE_INPUT_GIT_REV_FILE}}

# Update nixos-pi configuration remotely.
switch-nixos-pi: update-git-rev
    NIX_SSHOPTS="-p 2222" nixos-rebuild switch --flake .#gjz010-nixos-pi-amd64 --use-remote-sudo --target-host 192.168.76.1 {{NIX_INJECT_FLAKE_INPUT_FLAGS}}
switch-server: update-git-rev
    NIX_SSHOPTS="-p 22" nixos-rebuild switch --flake .#gjz010-nixos-server --use-remote-sudo --target-host server.gjz010.com {{NIX_INJECT_FLAKE_INPUT_FLAGS}}

# nixos-switch on remote device.
nixos-switch-remote system hostname: update-git-rev
    nixos-rebuild switch --flake .#{{system}} --use-remote-sudo --target-host {{hostname}} {{NIX_INJECT_FLAKE_INPUT_FLAGS}}
# nixos-boot on remote device.
nixos-boot-remote system hostname: update-git-rev
    nixos-rebuild boot --flake .#{{system}} --use-remote-sudo --target-host {{hostname}} {{NIX_INJECT_FLAKE_INPUT_FLAGS}}
# Install NixOS on a device using nixos-anywhere. The ssh_keys should be a folder containing `etc`.
nixos-anywhere-remote system hostname ssh_keys: (build-nixos-drv system)
    nixos-anywhere -s result-disko result-nixos --extra-files {{ssh_keys}} {{hostname}}

build-pi-sdimage: update-git-rev
    nix build .#nixosConfigurations.nixos-pi.config.system.build.sdImage {{NIX_INJECT_FLAKE_INPUT_FLAGS}}
build-nixos-drv system: update-git-rev
    nix build .#nixosConfigurations.{{system}}.config.system.build.toplevel {{NIX_INJECT_FLAKE_INPUT_FLAGS}} -o result-nixos
    nix build .#nixosConfigurations.{{system}}.config.system.build.diskoScript {{NIX_INJECT_FLAKE_INPUT_FLAGS}} -o result-disko


nixos-build: update-git-rev
    nixos-rebuild build --flake . {{NIX_INJECT_FLAKE_INPUT_FLAGS}}
nixos-switch: update-git-rev
    sudo proxychains4 nixos-rebuild switch --flake . {{NIX_INJECT_FLAKE_INPUT_FLAGS}}
nixos-boot: update-git-rev
    sudo proxychains4 nixos-rebuild boot --flake . {{NIX_INJECT_FLAKE_INPUT_FLAGS}}
encrypt:
    ./scripts/secrets-embedded.ts --encrypt
decrypt:
    ./scripts/secrets-embedded.ts --decrypt
encrypt_check:
    ./scripts/secrets-embedded.ts --encrypt --nonew
