---
name: add-feature
description: "Create or modify dendritic modules in modules/features/."
version: 0.1.0
author: Ivy (coucoucl0vr), Hermes Agent
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [nixos, dendritic, modules, features, flake-parts]
    related_skills: [nix-lookup, commit]
---

# Adding a Feature Module

Every `.nix` file under `modules/` is auto-imported by `import-tree` via `flake.nix`.
Flake evaluation only sees git-tracked files: new modules must be staged with `git add` to be visible to Nix.

## When to Use

- Adding system or user-level functionality to `modules/features/*.nix`
- Editing existing feature modules or their submodules
- Wiring new flake-parts modules into host definitions
- Don't use for: standalone AppImage packaging (use `add-package`)

## Module Skeleton

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
        # Only declare options hosts need to configure
      };

      config = {
        # ...
      };
    };
}
```

## Home Manager Rules

There is no standalone `home.nix`. Home Manager config is defined inside feature modules using flake lib helpers:

```nix
home-manager.users = self.lib.applyDesktopHome config (username: {
  home.packages = with pkgs; [ ... ];
});
```

- Never set `home.stateVersion` (injected centrally in `modules/features/users.nix`).
- When Home Manager's own `lib` is needed (e.g. `lib.hm.dag.entryAfter`), wrap the inner function arguments: `(username: { lib, ... }: { ... })`.
- Unfree packages go through `features.core.unfreePackages`, not bare `allowUnfree`.

## Procedure

1. Write `modules/features/<name>.nix` (or `modules/features/<name>/default.nix`).
2. Run `terminal(command="git add modules/features/<name>.nix")` so Nix can see the file.
3. Wire `self.nixosModules.<name>` into `modules/hosts/TheUnreliable/default.nix`.
4. Test eval/build: `terminal(command="nh os build .")`.
5. Format: `terminal(command="nixfmt modules/features/<name>.nix")`.

## Pitfalls

- Untracked files fail silently during flake evaluation — build will pass without applying the new module. Always `git add`.
- Only declare `options.features.<name>` if the host needs to configure it. Pure installation modules need only `config`.
