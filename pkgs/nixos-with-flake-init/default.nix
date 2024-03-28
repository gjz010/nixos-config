{writeShellScriptBin, nixos-install-tools, nix, git, mkpasswd, gnused
, gjz010Flake}:
writeShellScriptBin "nixos-with-flake-init" ''
  export PATH=${nix}/bin:${nixos-install-tools}/bin:${git}/bin:${mkpasswd}/bin:${gnused}/bin:$PATH
  gjz010Flake=${gjz010Flake}
  echo "==================================================="
  echo "NixOS With Flake Initializer by gjz010"
  echo "==================================================="
  echo
  config_dir=$(pwd)
  if [ "$(ls -A $config_dir)" ]; then
    echo "==================================================="
    echo "This script should be run in an empty directory!"
    echo "==================================================="
    exit 1
  fi
  
  echo "==================================================="
  echo "What will be the hostname of your system?"
  read -p "Hostname (default: nixos): " installation_hostname
  if [ -z "$installation_hostname" ]; then
    installation_hostname="nixos"
  fi
  echo "==================================================="
  echo
  echo "==================================================="
  echo "And what is your username?"
  while [ -z "$installation_username" ]; do
    read -p "Username: " installation_username
    if [ -z "$installation_username" ]; then
      echo "Username cannot be empty. Please try again."
    fi
  done
  echo "==================================================="
  echo
  echo "==================================================="
  echo "And the password for user $installation_username ?"
  while [ -z "$installation_password_hash" ]; do
    read -s -p "Password: " installation_password
    echo
    if [ -z "$installation_password" ]; then
      echo "Password cannot be empty. Please try again."
    else
      read -s -p "Confirm password: " installation_password_confirmation
      echo
      if [ "$installation_password" != "$installation_password_confirmation" ]; then
        echo "Passwords do not match. Please try again."
      else
        installation_password_hash=$(mkpasswd "$installation_password")
      fi
      # Unset temporary variables
      installation_password=""
      installation_password_confirmation=""
    fi
  done
  echo "==================================================="
  echo
  echo "==================================================="
  echo "Initializing flake template"
  nix --experimental-features "nix-command flakes" flake init -t $gjz010Flake#nixos-with-flake
  echo "==================================================="
  echo
  echo "==================================================="
  echo "Running nixos-generate-config"
  nixos-generate-config --root /mnt --dir $config_dir 


  installation_username_nospace=$(echo "$installation_username" | sed "s/ /-/g")
  echo "Writing customization to configuration set."

  # Replace hostname
  sed -i "s/nixos-desktop-alice/$installation_hostname/" flake.nix

  # Instantiate user from alice
  sed -i "s/alice/\"$installation_username\"/" users/alice.nix
  # Escape the hashed password
  # https://unix.stackexchange.com/questions/255789/is-there-a-way-to-prevent-sed-from-interpreting-the-replacement-string
  installation_password_hash_escaped=$(sed -e 's/[&\\/]/\\&/g; s/$/\\/' -e '$s/\\$//' <<<"$installation_password_hash")
  sed -i "s/hashedPassword = null/hashedPassword = \"$installation_password_hash_escaped\"/" users/alice.nix
  mv users/alice.nix users/$installation_username_nospace.nix
  sed -i "s/alice\.nix/$installation_username_nospace.nix/" flake.nix
  echo "==================================================="
  echo
  echo "==================================================="
  echo "Adding everything to git version control"
  git init
  git add .
  git_name=$(git config --global --get user.name)
  if [ -z "$git_name" ]; then
    echo "user.name not set, using default"
    export GIT_AUTHOR_EMAIL="nixos-with-flake-init"
    export GIT_AUTHOR_NAME="nixos-with-flake-init@no-reply.gjz010.com"
    export GIT_COMMITTER_EMAIL="nixos-with-flake-init"
    export GIT_COMMITTER_NAME="nixos-with-flake-init@no-reply.gjz010.com"
    git commit -m "Initial commit."
  else
    git commit -m "Initial commit."
  fi
  echo "==================================================="
  echo
  echo "==================================================="
  echo "Done! Now edit your configuration, namely:"
  echo "- Edit "configuration.nix" to match your needs."
  echo "- Git add (and optionally commit) everything. "
  echo "After configuring your installation, just run \"nixos-install --flake .#$installation_hostname\""
  echo ===================================================
''