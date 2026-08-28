---
name: add-package
description: Package software that isn't in nixpkgs as a flake package under modules/packages/. Use when asked to package an AppImage, a GitHub release binary, or any app not available in nixpkgs; to bump the version of an existing custom package; or to wrap an existing package with custom config.
---

# Adding a standalone package

Check first that the package genuinely isn't in nixpkgs — use the `nix-lookup`
skill. Packaging something that already exists upstream is wasted work.

Files live in `modules/packages/<name>.nix` and are auto-imported by
`import-tree`. The shape is a flake-parts `perSystem`:

```nix
{ self, inputs, ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    {
      packages.<name> = ...;
    };
}
```

## AppImage — the common case

Copy the structure of `modules/packages/openwork.nix` rather than improvising.
The parts that matter:

```nix
let
  pname = "<name>";
  version = "1.2.3";

  sources = {
    x86_64-linux = { url = "..."; hash = "sha256-..."; };
    aarch64-linux = { url = "..."; hash = "sha256-..."; };
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
      # install the .desktop file and rewrite Exec=AppRun → Exec=${pname}
      # copy icons out of ${appimageContents}/usr/share/icons
    '';
    meta = { ... mainProgram = "<name>"; };
  };
}
```

The explicit `throw` on unsupported systems gives a readable error instead of an
"attribute missing". The `Exec=AppRun` rewrite is required or the desktop entry
launches nothing.

### Getting the hash

```sh
nix hash convert --hash-algo sha256 --to sri "$(nix-prefetch-url <url>)"
```

Or write `hash = lib.fakeHash;`, build, and read the correct hash out of the
mismatch error.

### Version bumps

Change `version`, then invalidate **every** per-system hash — replace each with
`lib.fakeHash` and rebuild once per system you actually build, or re-prefetch
each URL. A stale hash on a non-native system won't fail until someone builds
for it.

## Other build styles

- Plain binaries / source builds → `pkgs.stdenv.mkDerivation`, usually with
  `autoPatchelfHook` for prebuilt ELFs.
- Software that insists on a normal filesystem → `pkgs.buildFHSEnv`.
- **Wrapping an existing package** with config baked in → use
  `inputs.wrapper-modules`, as in `modules/features/niri.nix` (`myNiri`) and
  `modules/features/noctalia/default.nix` (`myNoctalia`). Note those live in
  *feature* modules alongside the NixOS config that consumes them, which is the
  right home when the wrapper only exists to serve one feature.

## Stage, build, install

```sh
git add modules/packages/<name>.nix
nix build .#<name>          # check the derivation alone before a full system build
./result/bin/<name>         # smoke test if it's runnable headlessly
```

Reference it from a feature module:

- inside a NixOS module: `self.packages.${pkgs.stdenv.hostPlatform.system}.<name>`
- inside a `perSystem`: `self'.packages.<name>`

For a user application, add it to the `let` block and `home.packages` list in
`modules/features/user-apps.nix` — follow the `openwork` line there. Unfree
packages also need an entry in `features.core.unfreePackages`.

Then delegate to **Verify**, and commit with scope `packages/<name>`.
