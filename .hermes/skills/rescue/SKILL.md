---
name: rescue
description: "Recover from bad rebuilds and manage generations."
version: 0.1.0
author: Ivy (coucoucl0vr), Hermes Agent
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [nixos, rollback, generations, boot, rescue]
    related_skills: [flake-update]
---

# Recovering and Managing Generations

## When to Use

- Rolling back to a previous generation after a broken switch
- System failed to boot or greeter/display manager broke
- Inspecting or deleting system generations
- Freeing disk space under severe disk pressure
- Don't use for: fixing syntax errors in a `.nix` file during standard build

## Build Verbs (Least Destructive First)

- `nh os build .` (`sbld`): Builds only. Safe, no activation.
- `nh os test`: Activates now without boot entry. Reboot returns to last good generation.
- `nh os boot`: Adds boot entry for next boot, does not activate now.
- `nh os switch` (`sup` / `nup`): Activates now and adds boot entry.

Use `nh os test` when testing greeters (`ly.nix`), compositor (`niri.nix`), PAM (`pam.nix`), or display drivers.

## Rollback Commands

Roll back immediately:
```sh
run0 nixos-rebuild switch --rollback
```
(Fish abbreviations: `soops`, `sback`, `noops`, `nback`)

Reboot into systemd-boot menu to choose an older generation:
```sh
systemctl reboot --boot-loader-menu=0
```
(Fish abbreviation: `reboot-to-menu`)

## Inspecting Failures

```sh
nixos-rebuild list-generations
systemctl --failed
journalctl -b -p err --no-pager | tail -50
```

## Pitfalls

- This machine uses **Lanzaboote Secure Boot** and **LUKS-encrypted root**. Kernel and bootloader changes affect signed EFI binaries; prefer `nh os boot` and deliberate reboot.
- Garbage collection (`nh clean all --keep 1` / `sclean`) removes older generations permanently. Ask confirmation before running.
