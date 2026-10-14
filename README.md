# Clover's awesome NixOS config!

This is the NixOS setup I run on **TheUnreliable**, my Framework Laptop 16 (Ryzen 7040HS with the RX 7700S dGPU). I'm on `nixos-unstable`, running [Niri](https://github.com/YaLTeR/niri) as my compositor with Noctalia Shell on top and Ly at the login screen.

## Features

- Home Manager as a NixOS module
- Secrets management via SOPS
- Secure Boot via Lanzaboote
- Automated `eduroam` IWD provisioning
- Battery-aware refresh rate and power profiles
- Gaming via Steam, Proton GE and `nix-citizen`

## How it's put together

I use the dendritic pattern here (`flake-parts` + `import-tree`), mostly because I got tired of maintaining giant `imports` lists by hand. Anything inside `modules/` gets picked up automatically. Each feature in `modules/features/` defines its own `features.<name>` option, and the host config in `modules/hosts/TheUnreliable/` just turns on whatever it needs.

Home Manager is wired straight into those same feature modules instead of living in a separate `home.nix`, so all the config for a program stays in one place instead of being split between system and user files.

## Using it

I use [`nh`](https://github.com/nix-community/nh) for rebuilds, mostly through a few fish abbreviations:

```sh
sup     # nh os switch
sug     # nh os switch --update --commit-lock-file
sbld    # nh os build .
soops   # roll back to the previous generation
```
