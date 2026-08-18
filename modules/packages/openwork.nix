{ self, inputs, ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    let
      pname = "openwork";
      version = "0.18.28";

      sources = {
        x86_64-linux = {
          url = "https://github.com/different-ai/openwork/releases/download/v${version}/openwork-linux-x86_64-${version}.AppImage";
          hash = "sha256-xdzNZRqHHNwyKB+ZlzRREBnZbUJTApeJvkTIDGq2xEw=";
        };
        aarch64-linux = {
          url = "https://github.com/different-ai/openwork/releases/download/v${version}/openwork-linux-arm64-${version}.AppImage";
          hash = "sha256-2NXFA45B/slr1HAreGK5pQqSg0hpgvw6wEMvoDoF1r4=";
        };
      };

      src = pkgs.fetchurl (
        sources.${pkgs.stdenv.hostPlatform.system}
          or (throw "Unsupported system for openwork: ${pkgs.stdenv.hostPlatform.system}")
      );

      appimageContents = pkgs.appimageTools.extract {
        inherit pname version src;
      };
    in
    {
      packages.openwork = pkgs.appimageTools.wrapType2 {
        inherit pname version src;

        extraInstallCommands = ''
          if [ -f ${appimageContents}/openwork.desktop ]; then
            install -m 444 -D ${appimageContents}/openwork.desktop -t $out/share/applications
            substituteInPlace $out/share/applications/openwork.desktop \
              --replace-warn 'Exec=AppRun' 'Exec=${pname}'
          elif [ -f ${appimageContents}/*.desktop ]; then
            install -m 444 -D ${appimageContents}/*.desktop -t $out/share/applications
            substituteInPlace $out/share/applications/*.desktop \
              --replace-warn 'Exec=AppRun' 'Exec=${pname}'
          fi
          cp -r ${appimageContents}/usr/share/icons $out/share/ 2>/dev/null || true
        '';

        meta = {
          description = "The open-source alternative to Claude Cowork (powered by opencode)";
          homepage = "https://github.com/different-ai/openwork";
          license = lib.licenses.mit;
          platforms = [
            "x86_64-linux"
            "aarch64-linux"
          ];
          mainProgram = "openwork";
        };
      };
    };
}
