---
name: nix-lookup
description: Verify that a NixOS option, Home Manager option, or nixpkgs package actually exists before writing it into the config. Use whenever about to write an unfamiliar option path or package attribute, when asked "does option X exist", "what's the option for X", "is X in nixpkgs", "what package provides X", or after an eval error about an undefined/renamed option.
---

# Verify before you write

This config tracks `nixos-unstable`. Options get renamed and removed there
constantly, and stable-release documentation is frequently wrong about it.

**Rule: do not write an option path or package attribute you have not confirmed
against the rev locked in `flake.lock`.** Not from memory, not from a web search
result that might describe a different channel. Every check below is fast — the
eval cost is a fraction of one failed system build.

## Does a package exist?

Fastest check, ~0.1s once evaluated:

```sh
nix eval --raw nixpkgs#ripgrep.meta.description
```

Failure means the attribute does not exist. Also useful:

```sh
nix eval --raw nixpkgs#<attr>.version
nix eval --raw nixpkgs#<attr>.meta.mainProgram     # the actual binary name
nix eval nixpkgs#<attr>.meta.unfree                # needs features.core.unfreePackages
```

When you don't know the attribute name, search — but note this evaluates the
whole package set and is slow (minutes) the first time:

```sh
nix search nixpkgs <term>
```

## Does an option exist?

Query this flake's own evaluated option set — authoritative for exactly what
this system will build:

```sh
nix eval --raw .#nixosConfigurations.TheUnreliable.options.programs.nh.enable.type.description
# → "boolean"

nix eval .#nixosConfigurations.TheUnreliable.options.<path>.default
nix eval --raw .#nixosConfigurations.TheUnreliable.options.<path>.description
```

An `attribute '<x>' missing` error is your answer: the option does not exist.

For the *currently running* system's evaluated value:

```sh
nixos-option services.openssh.enable
```

## Home Manager options

HM options are **not** in the NixOS option set — querying
`nixosConfigurations...options.programs.zen-browser` will not find them. Reach
them through the HM module inside the system config:

```sh
nix eval --raw .#nixosConfigurations.TheUnreliable.options.home-manager.users.type.description
```

In practice it is usually faster to read the source (below) for HM.

## Read the source — the last word

For anything renamed, deprecated, or suspicious, grep the locked source. This
resolves the *exact* rev in `flake.lock`, not whatever your channel points at:

```sh
NIXPKGS=$(nix eval --raw .#inputs.nixpkgs.outPath)
grep -rn "mkRenamedOptionModule\|mkRemovedOptionModule" "$NIXPKGS/nixos/modules/rename.nix" | grep -i <term>
grep -rn "<optionName>" "$NIXPKGS/nixos/modules/" | head

HM=$(nix eval --raw .#inputs.home-manager.outPath)
grep -rn "<optionName>" "$HM/modules/" | head
```

`rename.nix` is the single best place to look when an option "used to work".

## Reporting

When you have checked, say what you checked against ("confirmed against the
locked nixpkgs rev"). When you could not confirm something, say that plainly
rather than writing it anyway and letting the build find out.
