{
  botamusique,
  python3,
  fetchFromGitHub,
  fetchNpmDeps,
  python3Packages,
  lib,
}:
(botamusique.override {
  python3Packages =
    (python3.override {
      packageOverrides = pyself: pysuper: {
        pymumble = (
          pysuper.pymumble.overrideAttrs (old: {
            pname = "pymumble";
            version = "1.7.0";
            src = fetchFromGitHub {
              owner = "LaikaBridge";
              repo = "pymumble";
              rev = "a4ff713b846772fb8215b78f94cd8fce3d82f3c9";
              hash = "sha256-FtvfME9k48L0M93yOEWOmJpExwOhLUTuwOpm3JH7Iw0=";
            };
          })
        );
        #yt-dlp = (
        #  pysuper.yt-dlp.overrideAttrs (old: {
        #    patches = [ ./11667-yt-dlp-bilibili-fix.patch ];
        #  })
        #);
      };
    }).pkgs;
}).overrideAttrs
  (
    f: p: rec {
      src = fetchFromGitHub {
        owner = "azlux";
        repo = "botamusique";
        rev = "2760a14f01004216ec1411c33f953b10c51bca09";
        hash = "sha256-WJgli+yDr3gF4LnnBv97PlEhxXBQENafpDPD2o5CBHM=";
      };
      npmDeps = fetchNpmDeps {
        src = "${src}/web";
        hash = "sha256-Pq+2L28Zj5/5RzbgQ0AyzlnZIuRZz2/XBYuSU+LGh3I=";
      };
      buildPhase =
        let
          buildPython = python3Packages.python.withPackages (ps: [ ps.jinja2 ]);
        in
        ''
          runHook preBuild

          # Generates artifacts in ./static
          (
            cd web
            npm run build
          )

          # Fills out http templates
          ${buildPython}/bin/python scripts/translate_templates.py --lang-dir lang/ --template-dir web/templates/

          runHook postBuild
        '';
      patches =
        (builtins.filter (p: !(lib.strings.hasInfix "catch-invalid-versions" "${p}")) p.patches)
        ++ [ ./botamusique.patch ];
    }
  )
