---
name: add-feature
description: Create or modify a dendritic feature module in modules/features/. Use when adding new system or user-level functionality to this NixOS config - "add a module for X", "enable X on this system", "install X system-wide", "configure X", "set up a systemd service for X", or when editing an existing modules/features/*.nix file.
---

# Adding a feature module

Every `.nix` file under `modules/` is auto-imported by `import-tree` (see
`flake.nix`). There is no index file to edit — but **flake evaluation only sees
git-tracked files**, so a new module is invisible until it is staged.

## 1. Pick the shape

- Single concern → `modules/features/<name>.nix`
- Several related concerns → `modules/features/<name>/default.nix` plus siblings.
  `modules/features/noctalia/` is the precedent: `default.nix`, `dependencies.nix`,
  `theming.nix`, all auto-imported independently.

Name the module after what it provides, not after the package.

## 2. Write the skeleton

The outer function is the **flake-parts** module; the inner one is the **NixOS**
module. Do not confuse their argument sets — `pkgs` and `config` only exist on
the inner one.

```nix
{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.<name> =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options.features.<name> = {
        # only declare options that a host actually needs to set
      };

      config = {
        # ...
      };
    };
}
```

References:
- `modules/features/nh.nix` — minimal module with one option.
- `modules/features/niri.nix` — real options (`mkOption`, `types.enum`,
  `nullOr`), plus a `perSystem` package in the same file.
- `modules/features/users.nix` — an `attrsOf (submodule ...)` option.

Only declare `options.features.<name>` when a host needs to configure it.
Modules that just install things (`browser.nix`, `user-apps.nix`) have `config`
alone.

Unfree packages go through `features.core.unfreePackages` (see
`modules/features/core.nix`), not a bare `allowUnfree`.

## 3. Home Manager rules

There is no standalone `home.nix`. HM config is written from inside the owning
feature module via the helper in `modules/lib.nix`:

```nix
home-manager.users = self.lib.applyDesktopHome config (username: {
  home.packages = with pkgs; [ ... ];
});
```

- **Never set `home.stateVersion`** — injected centrally in
  `modules/features/users.nix`.
- If you need Home Manager's own `lib` (e.g. `lib.hm.dag.entryAfter`), wrap the
  inner function so HM's `lib` shadows the outer one:
  ```nix
  self.lib.applyDesktopHome config (
    username:
    { lib, ... }:
    { home.activation.foo = lib.hm.dag.entryAfter [ "linkGeneration" ] ''...''; }
  )
  ```
  See `modules/features/ssh.nix`. Getting this wrong yields a confusing
  "attribute 'hm' missing".
- External HM modules from flake inputs are imported via
  `home-manager.sharedModules` in the module that owns them — see
  `modules/features/browser.nix` (`zen-browser`) and `flatpak.nix`.

`self.lib.getDesktopUsers config` returns the usernames if you need the list
directly.

## 4. Stage the file — required, not tidiness

```sh
git add modules/features/<name>.nix
```

Do this **before** any build. An untracked file does not exist as far as
`nix` is concerned, and the failure mode is silent: the build succeeds and your
module simply is not there.

## 5. Wire it into the host

Add `self.nixosModules.<name>` to the module list in
`modules/hosts/TheUnreliable/default.nix`, in the matching commented section
(`# system`, `# home`, or the greeter block). Keep the sections meaningful.

If the module is a greeter/display manager: `modules/hosts/TheUnreliable/configuration.nix`
carries an assertion that exactly one greeter is enabled. Comment out the
current one (`self.nixosModules.ly`) in the same change or the build fails.

Host-specific values (hostname, users, unfree whitelist) belong in
`configuration.nix`, not in the feature module.

## 6. Format and verify

```sh
nixfmt modules/features/<name>.nix
```

Then delegate to the **Verify** agent to run the build. If it fails with a long
log, delegate to **Triage** to extract the real error rather than reading the
log yourself.

Do not run `nh os switch` unless asked — building is enough to prove the change.

## 7. Commit

Use the `commit` skill. Scope is `features/<name>`.
