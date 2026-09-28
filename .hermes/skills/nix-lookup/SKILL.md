---
name: nix-lookup
description: "Verify NixOS and Home Manager options or packages exist."
version: 0.1.0
author: Ivy (coucoucl0vr), Hermes Agent
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [nixos, nixpkgs, options, eval, flake]
    related_skills: [add-feature, add-package]
---

# Nix Lookup

Verify that a NixOS option, Home Manager option, or nixpkgs package actually exists before writing it into the config. This config tracks `nixos-unstable` where options get renamed or removed often.

## When to Use

- Before writing an unfamiliar NixOS or Home Manager option path
- Before adding a package attribute from nixpkgs
- After an eval error reports an undefined, missing, or renamed option
- Don't use for: AppImages or external tarballs not in nixpkgs (use `add-package`)

## Quick Reference

Hermes tools used: `terminal` for queries, `read_file` or `search_files` for source inspection.

```sh
# Package checks
nix eval --raw nixpkgs#ripgrep.meta.description
nix eval --raw nixpkgs#<attr>.version
nix eval --raw nixpkgs#<attr>.meta.mainProgram
nix eval nixpkgs#<attr>.meta.unfree

# NixOS option checks (evaluated against this flake)
nix eval --raw .#nixosConfigurations.TheUnreliable.options.programs.nh.enable.type.description
nix eval .#nixosConfigurations.TheUnreliable.options.<path>.default
nix eval --raw .#nixosConfigurations.TheUnreliable.options.<path>.description

# Live running system option value
nixos-option services.openssh.enable
```

## Source Inspection

When an option used to work or cannot be found, grep the locked flake inputs directly:

```sh
NIXPKGS=$(nix eval --raw .#inputs.nixpkgs.outPath)
grep -rn "mkRenamedOptionModule\|mkRemovedOptionModule" "$NIXPKGS/nixos/modules/rename.nix" | grep -i <term>
grep -rn "<optionName>" "$NIXPKGS/nixos/modules/" | head

HM=$(nix eval --raw .#inputs.home-manager.outPath)
grep -rn "<optionName>" "$HM/modules/" | head
```

## Pitfalls

- Stable-release documentation frequently mismatches `nixos-unstable`. Always check against the locked rev in `flake.lock`.
- Home Manager options are nested under `home-manager.users.*` and are not top-level NixOS options.
