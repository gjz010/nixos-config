{writeShellScriptBin, nixos-install-tools, nix, git, gjz010Flake}:
writeShellScriptBin "nixos-with-flake-init" ''
  export PATH=${nix}/bin:${nixos-install-tools}/bin:${git}/bin:$PATH
  echo "NixOS With Flake Initializer by gjz010"
  config_dir=$(pwd)
  if [ "$(ls -A $config_dir)" ]; then
    echo "This script should be run in an empty directory!"
    exit 1
  fi

  echo "Initializing flake template"
  nix flake init -t ${gjz010Flake}#nixos-with-flake
  echo "Running nixos-generate-config"
  nixos-generate-config --dir $config_dir
  echo "Adding everything to git version control"
  git init
  git add .
  git_name=$(git config --global --get user.name)
  if [ -z "$git_name" ]; then
    echo "user.name not set, using default"
    git commit --author="nixos-with-flake-init <>" -m "Initial commit."
  else
    git commit -m "Initial commit."
  fi
  echo Done! Now edit your configuration and run "nixos-install --flake ." .
''