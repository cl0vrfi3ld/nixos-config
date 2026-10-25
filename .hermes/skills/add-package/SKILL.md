---
name: add-package
description: "Package software not in nixpkgs under modules/packages/."
version: 0.1.0
author: Ivy (coucoucl0vr), Hermes Agent
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [nixos, packaging, appimage, flake, derivations]
    related_skills: [nix-lookup, add-feature]
---

# Adding a Standalone Package

Check first that the package genuinely is not in nixpkgs using `nix-lookup`. Standalone packages live in `modules/packages/<name>.nix` and are auto-imported via `import-tree`.

## When to Use

- Packaging an AppImage, GitHub release binary, or custom tool
- Wrapping an application not yet upstreamed in nixpkgs
- Bumping versions and hashes for custom derivations under `modules/packages/`
- Don't use for: packages already in nixpkgs

## AppImage Structure

Follow `modules/packages/openwork.nix`:

```nix
{ self, inputs, ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    let
      pname = "<name>";
      version = "1.2.3";
      sources = {
        x86_64-linux = {
          url = "...";
          hash = "sha256-...";
        };
      };
      src = pkgs.fetchurl (
        sources.${pkgs.stdenv.hostPlatform.system}
          or (throw "Unsupported system for ${pname}: ${pkgs.stdenv.hostPlatform.system}")
      );
      appimageContents = pkgs.appimageTools.extract { inherit pname version src; };
    in
    {
      packages.<name> = pkgs.appimageTools.wrapType2 {
        inherit pname version src;
        extraInstallCommands = ''
          # Install desktop file, rewrite Exec=AppRun -> Exec=${pname}
          # Copy icons out of ${appimageContents}/usr/share/icons
        '';
        meta = {
          mainProgram = "<name>";
        };
      };
    };
}
```

## Tauri Apps

Start with the upstream AppImage via `appimageTools.wrapType2`; it is minutes of work and usually fine (`modules/packages/buzz.nix`). Build from source only when the AppImage cannot be made to work, you need native Wayland (linuxdeploy's AppRun forces `GDK_BACKEND=x11`), or there is no Linux release. Source builds are hours of work and a ~15 minute compile per bump (`modules/packages/buzz-source.nix`).

### AppImage

- Find missing libraries before launching: list `patchelf --print-needed` across `usr/bin` and `usr/lib` of `appimageTools.extract`, check each against the AppImage and the env's `fhsenv-rootfs`, and add the gaps to `extraPkgs` (Buzz needed `elfutils`, `libffi`, `zstd`).
- GStreamer: these AppImages strip their own and expect the host's. Add `gst_all_1.gst-plugins-good` and `-bad` to `extraPkgs`, and export `GST_PLUGIN_PATH_1_0=/usr/lib64/gstreamer-1.0` in `profile`. The launcher unsets the *system* path, not this one. Without it WebKit logs `GStreamer element appsink not found` and audio breaks.
- Set `executableName` to the app's own binary name (e.g. `buzz-desktop`), not the bare product name. Tauri apps that bundle a CLI symlink it to `~/.local/bin/<name>` on every launch, which shadows the profile, so a wrapper named after the product silently becomes the CLI.
- The desktop file usually says `Exec=<binary>` rather than `AppRun`; read it from the extracted tree rather than guessing. Add `%u` when it declares an `x-scheme-handler` MimeType, or deep links never arrive.

### From source

Use `rustPlatform.buildRustPackage` + `cargo-tauri.hook`; nixpkgs `readest` is a good reference. `buildFHSEnv` around the result is still worth it if the app downloads generic Linux binaries at run time.

- Use `pnpm_11` + `pnpmConfigHook` + `fetchPnpmDeps { fetcherVersion = 4; }`; set `cargoRoot` and `buildAndTestSubdir` to the `src-tauri` dir when the Tauri crate has its own Cargo.lock.
- Read upstream's Linux release workflow (`.github/workflows/release.yml`) first: it names the cargo features, the sidecar crates and the env vars the real build uses.
- `bundle.externalBin` sidecars must exist at `src-tauri/binaries/<name>-<rust-target-triple>` before `tauri build`. If they come from a different Cargo workspace, build them as a separate derivation and `install` them in `preBuild`.
- Build scripts that download prebuilt archives (e.g. sherpa-onnx-sys) need the archive pre-fetched and pointed at via their override env var (`SHERPA_ONNX_ARCHIVE_DIR`); check each `-sys` crate's build.rs.
- `audiopus_sys` links opus dynamically on glibc: add `libopus` to buildInputs or the final link fails with `cannot find -lopus`.
- `libappindicator-sys` dlopens by bare soname: substitute an absolute path in `$cargoDepsCopy/*/libappindicator-sys-*/src/lib.rs`.
- Add `cmake` + `dontUseCmakeConfigure = true` for vendored C deps, and `doCheck = false` when tests need live services.
- Get all fixed-output hashes in one pass: `nix build --keep-going --no-link .#pkg.pnpmDeps .#pkg.cargoDeps .#pkg.sidecars.cargoDeps`.
- Linking a big Tauri lib can take over 6 GB of RAM and several minutes; it is not hung.

### Testing either kind

- The window may start `visible: false` and only show once the webview is ready; check `niri msg -j windows` for the app_id before assuming it failed to open.
- Stuck on the loading screen, with `crashAfter10Seconds` / `AudioDestinationGStreamer::startRendering` in `coredumpctl info`: WebKit blocks on the audio sink starting, so the host's PipeWire graph is wedged, not the package. Confirm with `timeout 6 pw-play --volume=0 <file>` (hangs too), then `systemctl --user restart wireplumber`. Seen after suspend/resume.
- Tauri apps use a D-Bus single-instance lock: a second launch hands off to an already-running copy and exits 0. Do NOT work around it with `dbus-run-session`: the private bus starts its own at-spi bus launcher, which overwrites `/run/user/$UID/at-spi/bus_0` and leaves a dead socket when it exits, breaking accessibility (and cua-driver) for every app started afterwards. Close the running instance instead; if it already happened, `systemctl --user restart at-spi-dbus-bus.service` fixes it.
- An agent integration showing "not installed" usually means a missing adapter binary (e.g. `claude-agent-acp`), not a sandbox PATH problem; read the app's discovery catalog for the exact command names before touching the wrapper.

## Hash Generation

```sh
nix hash convert --hash-algo sha256 --to sri "$(nix-prefetch-url <url>)"
```
Or set `hash = lib.fakeHash;`, build, and read the expected hash from the mismatch error.

## Procedure

1. Write `modules/packages/<name>.nix`.
2. Run `terminal(command="git add modules/packages/<name>.nix")`.
3. Build derivation: `terminal(command="nix build .#<name>")`.
4. Test binary: `terminal(command="./result/bin/<name> --version")`.
5. Expose in `modules/features/user-apps.nix` or appropriate feature module.

## Pitfalls

- Rewriting `Exec=AppRun` to `Exec=<name>` in the desktop file is required or the app will fail to launch from desktop runners.
- When bumping versions, invalidate every per-system hash (e.g., replace with `lib.fakeHash`) to avoid stale hashes on non-native targets.
