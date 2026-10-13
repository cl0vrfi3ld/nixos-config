# Clover's awesome NixOS config!

My personal NixOS setup. One laptop, one flake, an unreasonable number of feature modules.

## Branch Details

### NixOS Branch

Unstable (`nixos-unstable`)

### Target Hosts

- **TheUnreliable**:
  Framework Laptop 16 (Ryzen 7040HS with RX 7700S dGPU)

### Desktop

- [Niri](https://github.com/YaLTeR/niri) scrollable-tiling compositor
- Noctalia Shell on top (the current daily driver)
- Ly as the login greeter
- DankMaterialShell is still in here, but deprecated and switched off

## Features

- Home Manager as a NixOS module
- Secrets management via SOPS
- Secure Boot via Lanzaboote
- Automated `eduroam` IWD provisioning
- Battery-aware refresh rate and power profiles
- Gaming via Steam, Proton GE and `nix-citizen`

## How it's put together

The config follows the **dendritic pattern** using `flake-parts` and `import-tree`. Every `.nix` file under `modules/` is imported automatically, so there are no index files to keep in sync. Each feature is its own little module that exposes a `features.<name>` option, and the host just picks which ones it wants.

```
modules/
├── hosts/TheUnreliable/   # host assembly, machine settings, hardware
├── features/              # one file per feature (gaming, networking, niri, ...)
└── packages/              # custom packages not in nixpkgs
```

Home Manager runs as a NixOS module, so there's no separate `home.nix`. Features write their own Home Manager config for every desktop user.

> [!NOTE]
> Flakes only see files tracked by git. If you add a new `.nix` file, `git add` it before building or it simply won't exist.

## Library helpers

`modules/lib.nix` exposes a couple of helpers as `flake.lib`, so any module can reach them through `self.lib`. They exist so feature modules never hardcode a username.

### `getDesktopUsers config`

Returns the usernames of every user in `features.users.users` with `isDesktopUser = true`. Mostly used by the helper below, but handy whenever something needs to loop over the humans on the machine.

### `applyDesktopHome config homeAttrs`

Builds a `home-manager.users` attrset with the same config for every desktop user. `homeAttrs` can be a plain attrset, or a function that takes the username:

```nix
home-manager.users = self.lib.applyDesktopHome config (username: {
  home.packages = with pkgs; [ firefox ];
});
```

If the config needs Home Manager's own `lib` (for things like `lib.hm.dag.entryAfter`), return a module function instead of an attrset. Home Manager then passes its `lib` in for you:

```nix
home-manager.users = self.lib.applyDesktopHome config (
  username:
  { lib, ... }:
  {
    home.activation.foo = lib.hm.dag.entryAfter [ "writeBoundary" ] "...";
  }
);
```

## Using it

Rebuilds go through [`nh`](https://github.com/nix-community/nh):

```sh
nh os switch    # build and switch (or `sup` in fish)
nh os boot      # build and apply on next boot
nh os build .   # just build, don't activate (or `sbld`)
```

Updating everything at once is `sug`, which runs `nh os switch --update --commit-lock-file`. If something breaks, `soops` rolls back to the previous generation.
