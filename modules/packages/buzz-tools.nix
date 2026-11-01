{ self, inputs, ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    let
      # Upstream only tags desktop releases; every crate in the workspace is
      # versioned 0.1.0. Track the same tag as buzz.nix so the CLI matches the
      # one bundled in the AppImage.
      version = "0.5.28";

      src = pkgs.fetchFromGitHub {
        owner = "block";
        repo = "buzz";
        tag = "desktop-v${version}";
        hash = "sha256-NEsLQwcoQ2zTgznFgGFGNgYPnoclicNVycSEjl7I0Wo=";
      };

      # Both binaries come from one Cargo workspace, so vendor it once.
      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        inherit src;
        name = "buzz-workspace-${version}";
        hash = "sha256-UQ8qNqoeDwkwhmVZebi++gb2GP61dr1Zv2QU9mJ6KJ8=";
      };

      # pname doubles as the workspace crate name.
      mkBuzzCrate =
        {
          pname,
          mainProgram,
          description,
        }:
        pkgs.rustPlatform.buildRustPackage {
          inherit
            pname
            version
            src
            cargoDeps
            ;

          cargoBuildFlags = [ "-p=${pname}" ];
          cargoTestFlags = [ "-p=${pname}" ];

          # reqwest's rustls backend uses rustls-platform-verifier, which
          # fails to build a client when it finds no CA store. The sandbox has
          # none; cacert's setup hook exports SSL_CERT_FILE for the tests.
          nativeCheckInputs = [ pkgs.cacert ];

          meta = {
            inherit description mainProgram;
            homepage = "https://github.com/block/buzz";
            license = lib.licenses.asl20;
            platforms = lib.platforms.linux;
          };
        };
    in
    {
      # Agent-first CLI for a Buzz relay. The binary is `buzz`, which is what
      # the desktop app links into ~/.local/bin on every start.
      packages.buzz-cli = mkBuzzCrate {
        pname = "buzz-cli";
        mainProgram = "buzz";
        description = "Agent-first CLI for the Buzz relay";
      };

      # Operator CLI. Talks to the relay's Postgres and Redis directly, so it
      # is only useful on (or tunnelled to) a host running buzz-relay.
      packages.buzz-admin = mkBuzzCrate {
        pname = "buzz-admin";
        mainProgram = "buzz-admin";
        description = "Operator CLI for Buzz relay administration";
      };
    };
}
