{stdenvNoCC, busybox, makeWrapper}:
stdenvNoCC.mkDerivation {
    name = "completion-test";
    phases = [ "installPhase" ];
    nativeBuildInputs = [ makeWrapper ];
    installPhase = ''
        mkdir -p $out/bin
        makeWrapper ${busybox}/bin/busybox $out/bin/completion-test --argv0 echo
        mkdir -p $out/share/bash-completion/completions
        cat << EOF > $out/share/bash-completion/completions/example-completion.sh
        complete -W "hello world completion test" completion-test
        EOF
        chmod +x $out/share/bash-completion/completions/example-completion.sh
    '';
}
