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
