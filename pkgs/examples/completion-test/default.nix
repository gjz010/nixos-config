{stdenvNoCC}:
stdenvNoCC.mkDerivation {
    name = "completion-test";
    phases = [ "installPhase" ];
    installPhase = ''
        mkdir -p $out/bash-completion/completions
        cat << EOF > $out/bash-completion/completions/example-completion.sh
        #!/usr/bin/env bash
        complete -W "hello world completion test" completion-test
        EOF
        chmod +x $out/bash-completion/completions/example-completion.sh
    '';
}
