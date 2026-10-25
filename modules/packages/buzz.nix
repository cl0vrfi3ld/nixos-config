{ self, inputs, ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    let
      pname = "buzz";
      version = "0.5.28";

      # Upstream only publishes a Linux build for x86_64.
      src = pkgs.fetchurl {
        url = "https://github.com/block/buzz/releases/download/desktop-v${version}/Buzz_${version}_amd64.AppImage";
        hash = "sha256-YCI6wn2HQiJqC149teH5dEGyZ/9jq7kFeTsz/mVoh0w=";
      };

      appimageContents = pkgs.appimageTools.extract { inherit pname version src; };
    in
    {
      # The upstream AppImage run inside appimageTools' FHS env. See
      # buzz-source.nix for the build from source.
      packages.buzz = pkgs.appimageTools.wrapType2 {
        inherit pname version src;

        # Not `buzz`: the app links its CLI to ~/.local/bin/buzz on every
        # start, which shadows the profile and turns `buzz` into the CLI.
        executableName = "buzz-desktop";

        extraPkgs =
          pkgs: with pkgs; [
            # Linked by the bundled binaries but missing from both the
            # AppImage and the default FHS profile.
            elfutils # libelf.so.1
            libffi # libffi.so.8
            zstd # libzstd.so.1
            # The AppImage strips its own GStreamer and expects the host's.
            # The default profile lacks good (autoaudiosink) and bad.
            gst_all_1.gst-plugins-good
            gst_all_1.gst-plugins-bad
          ];

        # Buzz's launcher unsets GST_PLUGIN_SYSTEM_PATH_1_0, so GStreamer falls
        # back to its compiled-in store path, which holds only the core
        # plugins. GST_PLUGIN_PATH_1_0 is searched in addition to that, and
        # the launcher leaves it alone because it points outside the AppImage.
        profile = ''
          export GST_PLUGIN_PATH_1_0=/usr/lib64/gstreamer-1.0''${GST_PLUGIN_PATH_1_0:+:$GST_PLUGIN_PATH_1_0}
        '';

        # Unique desktop file and icon names, so this can sit next to
        # buzz-source without colliding.
        extraInstallCommands = ''
          install -m 444 -D ${appimageContents}/Buzz.desktop \
            $out/share/applications/${pname}.desktop
          substituteInPlace $out/share/applications/${pname}.desktop \
            --replace-fail 'Exec=buzz-desktop' 'Exec=buzz-desktop %u' \
            --replace-fail 'Icon=buzz-desktop' 'Icon=${pname}'
          for icon in ${appimageContents}/usr/share/icons/hicolor/*/apps/buzz-desktop.png; do
            size=$(basename "$(dirname "$(dirname "$icon")")")
            install -m 444 -D "$icon" $out/share/icons/hicolor/$size/apps/${pname}.png
          done
        '';

        meta = {
          description = "Hive mind communication platform for humans and agents (upstream AppImage)";
          homepage = "https://github.com/block/buzz";
          license = lib.licenses.asl20;
          sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
          platforms = [ "x86_64-linux" ];
          mainProgram = "buzz-desktop";
        };
      };
    };
}
