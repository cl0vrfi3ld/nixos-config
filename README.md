# Clover's awesome NixOS config!

This is the NixOS setup for **TheUnreliable**, my Framework Laptop 16 (Ryzen 7040HS + RX 7700S). I'm on `nixos-unstable`, running [Niri](https://github.com/YaLTeR/niri) with Noctalia Shell on top and Ly at the login screen.

## Features

- Home Manager as a NixOS module
- Secrets management via SOPS
- Secure Boot via Lanzaboote
- Automated `eduroam` IWD provisioning
- Battery-aware refresh rate and power profiles
- Gaming via Steam, Proton GE and `nix-citizen`

## How it's put together

I use the dendritic pattern here (`flake-parts` + `import-tree`), mostly because I got tired of maintaining giant `imports` lists by hand. Anything dropped into `modules/` gets picked up automatically. Each file in `modules/features/` is its own module with a `features.<name>` toggle, and the host config just turns on whatever it needs.

Home Manager is wired straight into those same feature modules rather than a separate `home.nix`, so all the config for a program actually stays in one place.

## Using it

Everything builds with [`nh`](https://github.com/nix-community/nh). Day to day I just use a few fish abbreviations:

```sh
sup     # nh os switch
sug     # nh os switch --update --commit-lock-file
sbld    # nh os build .
soops   # roll back when I break something
```
