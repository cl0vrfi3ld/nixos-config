---
name: rescue
description: Recover from a bad NixOS rebuild and manage generations on this host. Use when asked to roll back, undo the last switch, boot an older generation, list or delete generations, free disk space / garbage collect, or when a switch failed, half-applied, or left the system broken.
---

# Recovering and managing generations

## Choose the least destructive verb

Escalate only as far as needed:

| Command | Effect |
| :--- | :--- |
| `nh os build .` (`sbld`) | Builds only. Nothing is activated. Always safe. |
| `nh os test` | Activates now, **no boot entry**. A reboot returns you to the last good generation. |
| `nh os boot` | Sets for next boot, does not activate now. |
| `nh os switch` (`sup`/`nup`) | Activates now and adds a boot entry. |

`nh os test` is the right choice for anything that could lock you out —
greeter (`ly.nix`), compositor (`niri.nix`), GPU (`gpu.nix`), PAM
(`pam.nix`), networking. If it goes wrong, reboot and you're back.

## Roll back

Previous generation:

```sh
run0 nixos-rebuild switch --rollback
```

Abbreviated as `soops`, `sback`, `noops`, or `nback`.

A specific generation — reboot into the bootloader menu and pick it:

```sh
systemctl reboot --boot-loader-menu=0     # abbreviated: reboot-to-menu
```

## Inspect before choosing

```sh
nixos-rebuild list-generations
```

Shows generation number, build date, NixOS version, kernel, and which is
current. To see what actually differs between two:

```sh
nix store diff-closures /nix/var/nix/profiles/system-{251,252}-link
```

## A switch that failed partway

Activation failures still leave the new boot entry in place, so "it failed"
does not automatically mean "roll back". Check what actually broke first:

```sh
systemctl --failed
journalctl -b -p err --no-pager | tail -50
```

A single failed service usually wants a fix in the relevant feature module, not
a rollback. Roll back when the system is unusable or you need a working
machine now.

## Disk space

Automatic cleanup is already configured in `modules/features/nh.nix`
(`clean.enable = true`, `--keep 3 --no-direnv --optimise`), so routine GC is not
needed. Only for real disk pressure:

```sh
nh clean all --keep 1     # abbreviated: sclean
```

This deletes old generations — you lose the ability to roll back to them.
Confirm with the user before running it, and never run it as a reflex after a
successful build.

## Boot-level breakage

This host uses **Lanzaboote Secure Boot** and a **LUKS-encrypted root**
(`modules/features/boot.nix`, `modules/hosts/TheUnreliable/hardware.nix`).

- First recourse for a bad kernel or boot change is the bootloader menu, not a
  live USB — older generations are signed and still bootable.
- Changes to `boot.nix`, the kernel, or the initrd affect signed EFI binaries.
  Flag secure-boot implications before touching them, and prefer `nh os boot`
  followed by a deliberate reboot over `nh os switch`.
- `boot.resumeDevice` and hibernation are configured in `hardware.nix`; changes
  to swap or partitions there can break resume without breaking boot, so test
  hibernation explicitly after touching them.
