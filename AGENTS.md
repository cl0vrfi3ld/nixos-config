# AGENTS.md

This file provides guidance to agents when working with code in this repository.

Personal NixOS configuration for the host **TheUnreliable** (Framework Laptop 16, AMD Ryzen 7040HS + Radeon RX 7700S). Tracks `nixpkgs` unstable. The desktop environment is the [Niri](https://github.com/YaLTeR/niri) scrollable-tiling Wayland compositor paired with the **Noctalia** shell. DankMaterialShell (DMS) is deprecated and inactive.

## Commands & Shortcuts

### Rebuild & System Management

```sh
# Rebuild & switch (uses nh, NH_FLAKE is set to this repo, elevates via run0)
nh os switch                                  # build + activate
nh os boot                                    # build + set for next boot
nh os test                                    # activate without adding a boot entry
nixos-rebuild switch --flake .#TheUnreliable  # equivalent without nh

# Evaluate / build without activating
nix build .#nixosConfigurations.TheUnreliable.config.system.build.toplevel
nix flake check                               # eval all outputs
nix flake show

# Build a perSystem package
nix build .#myNiri                            # wrapped Niri compositor
nix build .#myNoctalia                        # wrapped Noctalia shell
nix build .#openwork                          # Openwork AppImage wrapper

# Secrets (sops IS in system packages via sops.nix)
sops secrets/default.yaml
```

`nh` garbage collection is enabled and configured with `clean.extraArgs = "--keep 3 --no-direnv --optimise"`.

### Fish Shell Abbreviations

The interactive user shell ([`modules/features/fish.nix`](file:///home/coucoucl0vr/nixos-config/modules/features/fish.nix)) provides convenient abbreviations:

| Abbreviation | Expanded Command | Purpose |
| :--- | :--- | :--- |
| `sup` / `nup` | `nh os switch /home/coucoucl0vr/nixos-config` | Build & switch to latest system + home configuration |
| `sug` / `nug` | `nh os switch --update --commit-lock-file /home/coucoucl0vr/nixos-config` | Update flake inputs and switch |
| `soops` / `sback` / `noops` / `nback` | `run0 nixos-rebuild switch --rollback` | Roll back to previous system generation |
| `sbld` | `cd /home/coucoucl0vr/nixos-config && nh os build .` | Test build without activating |
| `sclean` | `nh clean all --keep 1` | Deep garbage collection |
| `info` | `fastfetch` | System info overview |
| `nixr` | `nix run nixpkgs#` | Quick prefix for running ephemeral nixpkgs binaries |
| `cgit` | `fj --host git.cl0vr.co` | Forgejo CLI for personal git instance |
| `reboot-to-menu` | `systemctl reboot --boot-loader-menu=0` | Reboot into systemd-boot / bootloader menu |

---

## Project Skills

Repo-specific procedures live in [`.claude/skills/`](file:///home/coucoucl0vr/nixos-config/.claude/skills) and load on demand:

| Skill | Fires when |
| :--- | :--- |
| `add-feature` | Adding or editing a `modules/features/*.nix` dendritic module — includes the Home Manager patterns, the mandatory `git add`, and host wiring. |
| `add-package` | Packaging an AppImage or other software not in nixpkgs under `modules/packages/`, or bumping a custom package's version. |
| `nix-lookup` | Before writing any unfamiliar option path or package attribute — verifies it against the rev locked in `flake.lock`. |
| `flake-update` | Updating inputs (all or one), summarizing what moved, and reverting a single bad input. |
| `rescue` | Rolling back, choosing between `build`/`test`/`boot`/`switch`, inspecting generations, or garbage collecting. |
| `hermes-nix` | Configuring Hermes Agent declaratively via `services.hermes-agent` in `modules/features/ai.nix` — settings, plugins, secrets, MCP servers; includes the `extraPythonPackages` clobber workaround. |
| `commit` | Writing a commit message in this repo's `<scope>: <summary>` convention, with an untracked-`.nix` check. |

The `Verify` and `Triage` agents cover building and log triage; the skills delegate to them rather than duplicating.

---

## Architecture

This repository follows the **dendritic pattern** powered by `flake-parts` and `import-tree`:

- **`modules/`** — root of all modular definitions. [`flake.nix`](file:///home/coucoucl0vr/nixos-config/flake.nix) imports `(inputs.import-tree ./modules)`, so **every `.nix` file under `modules/` is auto-imported as a flake-parts module** without manual index files or lists.
- **IMPORTANT**: Flakes only evaluate files tracked in git. Any newly created `.nix` file or asset must be staged (`git add <file>`) before `nix` or `import-tree` can see it.

### Layout of `modules/`

```
modules/
├── lib.nix                   # Flake library helpers (flake.lib)
├── hosts/
│   └── TheUnreliable/        # Host configuration for Framework 16
│       ├── default.nix       # nixosSystem assembly & module imports
│       ├── configuration.nix # Host features config, assertions & machine settings
│       └── hardware.nix      # Declarative hardware, LUKS, filesystems & hibernation
├── packages/                 # Standalone flake packages (perSystem.packages)
│   └── openwork.nix          # Openwork AppImage package
└── features/                 # Modular NixOS & Home Manager features
    ├── ai.nix                # Hermes Agent service, CLI & desktop app (gated by features.ai)
    ├── battery.nix           # Dynamic refresh rate & power profile daemons
    ├── bitwarden.nix         # Bitwarden desktop & electron overrides
    ├── boot.nix              # Lanzaboote Secure Boot & Plymouth theme
    ├── browser.nix           # Zen Browser twilight module
    ├── compat.nix            # AppImage & nix-ld binaries compatibility
    ├── core.nix              # Locale, timezone, nix settings & base utils
    ├── desktop-suite.nix     # Core desktop utilities, KDE apps & fonts
    ├── dev.nix               # Dev tools, IDEs (VS Codium, Kate, Zed, android-studio, IntelliJ FHS) & AI agents
    ├── dms.nix               # DankMaterialShell (deprecated / inactive)
    ├── fish.nix              # Fish shell & abbreviations
    ├── flatpak.nix           # Declarative Flatpaks (Trayscale, PikaBackup, SyncThingy)
    ├── gaming.nix            # Steam, Proton GE, Gamescope, VR, Sunshine, RSI Launcher
    ├── gpu.nix               # AMD OpenCL support
    ├── ly.nix                # Ly display manager (active greeter)
    ├── networking.nix        # NetworkManager + IWD, eduroam provisioning, Tailscale, Mullvad
    ├── nh.nix                # nh CLI helper & auto-clean
    ├── niri.nix              # Niri Wayland compositor wrapper
    ├── noctalia/             # Noctalia desktop shell
    │   ├── default.nix       # noctalia package wrapper & niri shell hook
    │   ├── dependencies.nix  # cliphist, wl-clip-persist
    │   └── theming.nix       # adw-gtk3-dark, cursor, qt6ct & nwg-look
    ├── pam.nix               # Fingerprint (fprintd) & fine-grained PAM services
    ├── security.nix          # Polkit & GNOME Keyring
    ├── sops.nix              # SOPS-Nix runtime secrets configuration
    ├── ssh.nix               # SSH client match blocks & permissions hook
    ├── sysc-greet.nix        # sysc-greet display manager module
    ├── tuigreet.nix          # greetd / tuigreet display manager module
    ├── user-apps.nix         # User desktop software (Vesktop, Obsidian, Openwork, Claude Desktop, etc.)
    ├── users.nix             # User accounts & Home Manager stateVersion injection
    ├── virtualisation.nix    # Podman container runtime & registries
    └── xdg-mime.nix          # Default XDG MIME file/protocol associations
```

---

## Dendritic Module Structure

Each `.nix` file inside `modules/` is a flake-parts module taking `{ self, inputs, lib, ... }` at the top level and exports one or both of:

1. **`flake.nixosModules.<name>`**: NixOS module declaring `options.features.<name>` and `config`. These are assembled into host configurations.
2. **`perSystem = { pkgs, self', ... }: { packages.<name> = ...; }`**: Buildable derivations (`myNiri`, `myNoctalia`, `openwork`), accessible as `self.packages.${system}.<name>` or `self'.packages.<name>`.

### Helper Library (`modules/lib.nix`)

Exported under `flake.lib` (available as `self.lib` across modules):

- **`self.lib.getDesktopUsers config`**: Returns a list of username strings for all users in `config.features.users.users` where `isDesktopUser = true`.
- **`self.lib.applyDesktopHome config homeAttrs`**: Generates a Home Manager configuration for every desktop user. `homeAttrs` can be an attribute set or a function `username: { ... }`.

### Home Manager Integration

- Runs as a NixOS module (`inputs.home-manager.nixosModules.home-manager`) with `useGlobalPkgs = true`, `useUserPackages = true`, and `backupFileExtension = "old"`.
- There is **no standalone `home.nix`**. Feature modules write Home Manager config via `home-manager.users = self.lib.applyDesktopHome config (username: { ... });`.
- External HM input modules are imported through `home-manager.sharedModules` in the owning feature module (e.g. `zen-browser` in `browser.nix`, `nix-flatpak` in `flatpak.nix`).
- `home.stateVersion = "25.05"` is centrally injected in [`modules/features/users.nix`](file:///home/coucoucl0vr/nixos-config/modules/features/users.nix), along with `home.username` and `home.homeDirectory` derived from `config.features.users.users`.
- `desktop-suite.nix` sets `org.freedesktop.impl.portal.Secret = [ "gnome-keyring" ]` in the portal config: xdg-desktop-portal uses the first config file it finds without merging, so the user-level portals.conf shadows the system's `niri-portals.conf`, and gtk's portal has no Secret backend — without this every Flatpak gets no keyring.
- `dev.nix` IDEs: `vscodium-fhs`, `kate`, `android-studio`, and a custom `intellij-idea-fhs` (`buildFHSEnv` wrapping `jetbrains.idea-oss`, run script `idea-oss`); Zed is wrapped as `zed-editor-fhs` with extra bwrap args that hide the dGPU so it stays in D0 (iGPU resolved via `/dev/dri/by-path/pci-0000:c5:00.0-*`). `nixpkgs.config.android_sdk.accept_license` is enabled here.
- When a Home Manager config requires Home Manager-specific library helpers (e.g. `lib.hm.dag.entryAfter`), wrap the function arguments as `(username: { lib, ... }: { ... })` so HM's own `lib` is used.

---

## Host Assembly (`TheUnreliable`)

[`modules/hosts/TheUnreliable/default.nix`](file:///home/coucoucl0vr/nixos-config/modules/hosts/TheUnreliable/default.nix) constructs `flake.nixosConfigurations.TheUnreliable` using `inputs.nixpkgs.lib.nixosSystem`:

- **Hardware**: [`modules/hosts/TheUnreliable/hardware.nix`](file:///home/coucoucl0vr/nixos-config/modules/hosts/TheUnreliable/hardware.nix) specifies the Framework 16 hardware (Ryzen 7040HS, Radeon RX 7700S, LUKS encrypted root & swap, Btrfs `/too` partition, `boot.resumeDevice`, power profiles daemon, ACPI backlight, and sleep/lid-switch handlers). `hardware-configuration.nix` is not tracked; hardware configuration is fully declarative here.
- **Host Configuration**: [`modules/hosts/TheUnreliable/configuration.nix`](file:///home/coucoucl0vr/nixos-config/modules/hosts/TheUnreliable/configuration.nix) sets hostname (`TheUnreliable`), timezone (`America/New_York`), unfree package whitelist (`castlabs-electron`, `antigravity`, `mathematica`), user accounts, and contains an **assertion enforcing that exactly one greeter is enabled**.
- **Active Features**: Imports active dendritic feature modules (`self.nixosModules.*`) and necessary flake input modules (`nixos-hardware`, `sops-nix`, `lanzaboote`, `nix-flatpak`, `nix-iwd-provisioning`, `nix-gaming`, `nix-citizen`).

---

## Desktop Environment & Compositor

### Niri Compositor Wrapper

- Packaged via `inputs.wrapper-modules` in [`modules/features/niri.nix`](file:///home/coucoucl0vr/nixos-config/modules/features/niri.nix) as `perSystem.packages.myNiri` (`pkgs.lib.makeOverridable`).
- When `features.niri.shell = "noctalia"`:
  - Keybindings are sourced from [`dotfiles/niri/noctalia-binds.kdl`](file:///home/coucoucl0vr/nixos-config/dotfiles/niri/noctalia-binds.kdl) via `pkgs.replaceVars` (substituting `@noctalia@` and `@ghostty@`).
  - Configures rounded window corners (20), layout gaps (8), autostarts Noctalia shell, and sets lid-close action to lock/suspend via Noctalia IPC.
- When `features.niri.raltCompose = true` (set in `configuration.nix`), xkb `compose:ralt` makes Right Alt the Compose key (e.g. RAlt s s → ß, RAlt " a → ä). This takes RAlt away from applications entirely — Wine games see the key as dead, not merely unmodified — so Star Citizen's RAlt binds need rebinding onto LAlt.
- When `features.niri.configPath` is set (e.g. for legacy DMS), build-time `niri validate` is bypassed to allow dynamic runtime `$HOME` Matugen theme includes.

### Noctalia Desktop Shell

- Wrapped in [`modules/features/noctalia/default.nix`](file:///home/coucoucl0vr/nixos-config/modules/features/noctalia/default.nix) via `inputs.wrapper-modules.wrappers.noctalia-shell.wrap` (`perSystem.packages.myNoctalia`).
- Submodules:
  - `theming.nix`: Sets Adwaita cursor (size 24), `adw-gtk3-dark` theme with window headerbar buttons hidden (`gtk-decoration-layout = ":"` for clean tiling), and Qt6CT theming.
  - `dependencies.nix`: Installs `cliphist` and `wl-clip-persist`.

### Display Managers & Greeters

- **Ly** ([`modules/features/ly.nix`](file:///home/coucoucl0vr/nixos-config/modules/features/ly.nix)) — **Currently Active** with matrix animation, big clock, and battery ID `BAT1`.
- **Tuigreet** ([`modules/features/tuigreet.nix`](file:///home/coucoucl0vr/nixos-config/modules/features/tuigreet.nix)) — Greetd tuigreet launcher (inactive/commented).
- **DMS Greeter** ([`modules/features/dms.nix`](file:///home/coucoucl0vr/nixos-config/modules/features/dms.nix)) — Quickshell-based DMS greeter (deprecated/commented).
- **Sysc-greet** ([`modules/features/sysc-greet.nix`](file:///home/coucoucl0vr/nixos-config/modules/features/sysc-greet.nix)) — Sysc-greet display manager module (inactive).

### Hardware & Battery Automation

[`modules/features/battery.nix`](file:///home/coucoucl0vr/nixos-config/modules/features/battery.nix) manages two background automation services, both built from the shared `mkPowerWatcher` helper (a debounced `upower --monitor` loop that only fires on an actual AC/battery transition):
1. `auto-rr-throttle` (systemd user service): Monitors power supply via `upower` and dynamically toggles the internal display `eDP-2` between **60Hz** (`2560x1600@60.002`) on battery and **165Hz** (`2560x1600@165.000`) on AC power using `niri msg`.
2. `power-profile-switcher` (systemd system service): Switches power profile daemon between `power-saver` (battery) and `performance` (AC).

---

## Secrets Management (SOPS)

- **Encryption**: Uses **Age** encryption (configured in [`.sops.yaml`](file:///home/coucoucl0vr/nixos-config/.sops.yaml)). Keys include user key `admin_clover` (`~/.config/sops/age/keys.txt`) and host key `machine_theseus` (converted from `~/.ssh/id_ed25519-age-system-theseus.pub`).
- **Decryption**: `sops-nix` decrypts secrets at **system activation / runtime** via a systemd unit using the private host key (`/home/coucoucl0vr/.ssh/id_ed25519-age-system-theseus`). Secrets are **never** decrypted into the Nix store at build time.
- **Paths**: Encrypted data is committed in [`secrets/default.yaml`](file:///home/coucoucl0vr/nixos-config/secrets/default.yaml) and decrypted to `/run/secrets/<name>` (e.g. `/run/secrets/iwd/eduroam/passwd`). The `hermes-agent` secret is YAML-format, group `users`, mode `0440`, and read by the Hermes Agent service via `environmentFiles`.
- **Editing Secrets**: Run `sops secrets/default.yaml` (sops is in system packages).

---

## Hermes Agent

Integrated in [`modules/features/ai.nix`](file:///home/coucoucl0vr/nixos-config/modules/features/ai.nix) (per desktop user) from the `hermes-agent` flake input (github:NousResearch/hermes-agent).

- The HM module is imported via `home-manager.sharedModules = [ inputs.hermes-agent.homeManagerModules.default ];`.
- `services.hermes-agent` (always on when the module is imported): `backend.mode = "serve"`, `backend.port = 9119`, `environmentFiles = [ config.sops.secrets."hermes-agent".path ]`.
- `programs.hermes-agent.enable` (the `hermes` CLI) is gated by `features.ai.hermes-agent.enable`; `programs.hermes-agent.desktop.enable` (the Electron app + launcher) by `features.ai.hermes-agent.desktop.enable`. Both default to `false` and are set to `true` in `configuration.nix`. The two are independent upstream.
- `openwork` and `claude-desktop` (from `inputs.llm-agents`) stay under "AI" in `user-apps.nix`'s `home.packages`.

---

## Conventions & Best Practices

- **Nix Formatting**: Follow `nixfmt` formatting style (2-space indents, trailing commas on attribute sets).
- **Adding Features**: Create `modules/features/<name>.nix` (or `modules/features/<name>/default.nix`) declaring `flake.nixosModules.<name>`, stage it with `git add`, and import `self.nixosModules.<name>` in [`modules/hosts/TheUnreliable/default.nix`](file:///home/coucoucl0vr/nixos-config/modules/hosts/TheUnreliable/default.nix).
- **Adding Standalone Packages**: Create `modules/packages/<name>.nix` exporting `perSystem = { pkgs, ... }: { packages.<name> = ...; };`, and stage it with `git add`.
- **First-time Setup / Symlinks**: [`link.sh`](file:///home/coucoucl0vr/nixos-config/link.sh) creates the `/etc/nixos` symlink pointing to `~/nixos-config` on new machines.
