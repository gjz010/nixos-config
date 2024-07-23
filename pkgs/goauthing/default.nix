{buildGoModule, fetchFromGitHub}:
buildGoModule {
    name = "auth-thu";
    version = "git-e42c2fd";
    vendorHash = "sha256-GRviH+w9WjjuvE0078NU4b9Hf/ZqBaQ9BxiWXeiGeWU=";
    src = fetchFromGitHub{
        owner = "z4yx";
        repo = "GoAuthing";
        rev = "e42c2fd7f02b157538940795597d82a8b8802ca8";
        hash = "sha256-D5WhTAZTsYXK3k0dtrC9xFDEY7R8p5LTM1mj68H2/0A=";
    };
    postInstall = ''
        mv $out/bin/cli $out/bin/auth-thu
    '';
}