---
name: hermes-nix
description: "Configure Hermes Agent declaratively via Home Manager."
version: 0.1.0
author: Ivy (coucoucl0vr), Hermes Agent
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [nixos, home-manager, hermes-agent, config, plugins, sops]
    related_skills: [add-feature, nix-lookup, flake-update, commit]
---

# Hermes Agent via Nix / Home Manager

Hermes is wired in `modules/features/ai.nix` through the upstream Home Manager module (`inputs.hermes-agent.homeManagerModules.default`, imported via `home-manager.sharedModules`) and applied per desktop user with `self.lib.applyDesktopHome`. `services.hermes-agent` owns state, `config.yaml`, `.env` and the daemons; `programs.hermes-agent` installs the CLI and desktop app. The install is **managed**: the CLI refuses to write config, so every durable change goes through Nix.

Upstream docs: <https://hermes-agent.nousresearch.com/docs/getting-started/nix-setup>. The module source at the locked rev is authoritative when the docs disagree — Nix is a Tier 2 platform upstream and `main` moves fast.

## When to Use

- Changing any Hermes setting (model, display, memory, tts, skills, terminal, …)
- Translating a `config.yaml` snippet or a `hermes config set` instruction into Nix
- Installing, enabling or configuring a plugin, MCP server, or optional dependency group
- Adding secrets/API keys, `SOUL.md`, memory seeds, or workspace documents
- Debugging "managed by home-manager" refusals, missing plugins, or config that won't stick
- Don't use for: generic feature-module scaffolding (`add-feature`), bumping the `hermes-agent` input (`flake-update`)

## Quick Reference

| Want | Nix (inside `services.hermes-agent` in `ai.nix`) |
| :--- | :--- |
| Any `config.yaml` key | `settings.<dotted.path> = <value>;` — see `references/settings-mapping.md` |
| API keys / tokens | add `KEY=value` lines to the `hermes-agent` sops secret (`sops secrets/default.yaml`) — already wired via `environmentFiles` |
| Non-secret env vars | `environment.FOO = "bar";` (lands in the world-readable store) |
| Identity / memory seed | `hermesHomeFiles."SOUL.md" = ./x.md;` / `hermesHomeFiles."memories/USER.md" = …;` |
| Workspace context | `documents."AGENTS.md" = …;` — **requires** an explicit `workingDirectory` |
| MCP server | `mcpServers.<name> = { command; args; env; }` or `{ url; headers; auth = "oauth"; }` |
| Directory plugin | `extraPlugins = [ src ];` + `settings.plugins.enabled = [ "<manifest-name>" ];` |
| Entry-point (pip) plugin | `package` override — see Plugins below (extraPythonPackages is currently broken) |
| pyproject extra | `extraDependencyGroups = [ "honcho" ];` (default package already ships the `full` set) |
| Binaries for the agent | `extraPackages = [ pkgs.pandoc ];` |
| Desktop/dashboard backend | `backend.mode = "serve" \| "dashboard"; backend.port = 9119;` |
| Messaging gateway | `gateway.enable = true;` (HM-only option; needs `users.users.<u>.linger = true` to survive logout) |
| Bypass merging entirely | `configFile = ./config.yaml;` (overwrites runtime edits every activation) |

Full option tables: `references/options.md`. Every valid leaf key: `terminal(command="nix build --no-link --print-out-paths --inputs-from . hermes-agent#configKeys")` then `read_file` the printed path (JSON list, ~930 keys).

## How `settings` becomes `config.yaml`

1. All `settings` definitions are folded with `lib.recursiveUpdate` (custom option type, so multiple modules can each set part of the tree).
2. `terminal.cwd = workingDirectory` is injected as a default (explicit `settings.terminal.cwd` wins — `ai.nix` sets `"."`), `_config_version` is stamped from the package's `DEFAULT_CONFIG`, and the result is rendered as JSON (valid YAML).
3. `mcpServers` is converted and merged into `settings.mcp_servers`.
4. On activation, a merge script deep-merges that into `~/.hermes/config.yaml` on disk: **Nix keys win, keys Nix doesn't mention survive** (runtime edits from the TUI/desktop settings panes are preserved).

Consequences you must reason about — see `references/settings-mapping.md` for worked translations:

- **Lists and scalars replace, never merge.** `settings.plugins.enabled = [ "a" ]` wipes any list already on disk. Two Nix modules setting the same list: last definition wins, no concatenation.
- **Deleting a key from Nix does not delete it from disk.** The merge only adds/overwrites. To revert, set the old value explicitly, or remove the key from `~/.hermes/config.yaml` by hand after the switch.
- **Priorities apply to whole definitions, not keys.** `settings = lib.mkForce { … }` discards *every other* `settings` definition, not just the overlapping keys.
- **Typos aren't caught at eval time.** `settings` is a free-form attrset; validate key paths against `configKeys`.

## Managed Mode

`~/.hermes/.managed` contains `home-manager` and services export `HERMES_MANAGED=home-manager`. While set, these refuse with an error naming `home-manager switch` (here: `nh os switch`, since HM runs as a NixOS module):

- `hermes setup`, `hermes config set|unset|edit`, any path through `save_config` (including `hermes plugins enable|disable` and plugin settings panes)
- `.env` writers (`hermes auth`-style key saves) — keys go into sops
- `hermes update` and `hermes gateway install|uninstall`

Read-only commands (`hermes config`, `hermes plugins list`, `hermes doctor`) work and are the right way to inspect the result.

## Plugins

Pick the mechanism by plugin shape:

| Plugin shape | Mechanism | Activation |
| :--- | :--- | :--- |
| Source tree with `plugin.yaml` + `__init__.py` at root | `extraPlugins` | `settings.plugins.enabled` |
| pip package registering `hermes_agent.plugins` entry point | `package` override with `extraPythonPackages` | `settings.plugins.enabled` |
| Memory provider (`kind: exclusive`) | either of the above | `settings.memory.provider = "<name>"` — **not** `plugins.enabled` |
| Optional extra in hermes' own `pyproject.toml` | `extraDependencyGroups` | per feature (`memory.provider`, `tts.provider`, …) |
| Python dep of a directory plugin | `extraPythonPackages` (via the override) | — |
| System binary a plugin shells out to | `extraPackages` | — |

Rules:

- `extraPlugins` entries are symlinked as `~/.hermes/plugins/nix-managed-<lib.getName drv>`; removing one from the list removes the symlink next switch. Activation **exits 1** if an entry has no root `plugin.yaml` (point at a subdirectory with `"${src}/plugins/foo"` if needed).
- Duplicate derivation names collide silently on the symlink — an assertion blocks it. With `fetchFromGitHub`, pass `name = "<plugin>";` since the default name is `source`.
- `plugins.enabled` matches the manifest `name` (or path-derived key), not the `nix-managed-*` directory name. Since the list replaces the on-disk one, include **every** plugin you want on, including ones installed imperatively before.
- Per-plugin config lives under `settings.plugins.<name>` (e.g. `plugins.memory-buckets.prefetch_min_similarity`).
- Build Python plugins against hermes' interpreter: `hermesBase.python.pkgs.callPackage …` / `.buildPythonPackage`. A build-time collision check fails the build if a plugin ships a package already in the sealed venv — drop that dependency from the plugin's inputs.

### Entry-point plugins: current workaround

`services.hermes-agent.extraPythonPackages` is broken at the current lock: the module's `effectivePackage` re-overrides `package` with `{ extraPythonPackages; extraDependencyGroups = cfg.extraDependencyGroups; }`, and `extraDependencyGroups` defaults to `[ ]`, which strips the ~18 optional groups the default (`full`) package was built with (anthropic, messaging, tts-premium, …). Upstream PR **#129837** fixes this. Until it lands, override the package directly as `ai.nix` already does:

```nix
services.hermes-agent = let
  hermesBase = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default;
  myPlugin = hermesBase.python.pkgs.callPackage ./my-plugin.nix { };
in {
  package = hermesBase.override { extraPythonPackages = [ myPlugin ]; };
  # Leave services.hermes-agent.extraPythonPackages and extraDependencyGroups unset —
  # setting either triggers the clobbering re-override.
};
```

After a `flake-update` pulls in #129837, check `effectivePackage` in the module source (see Verification) and, if fixed, move the plugin back to `extraPythonPackages` and drop the override comment in `ai.nix`.

## Procedure

1. **Locate the key.** Find the `config.yaml` path (from docs, `hermes config`, or `configKeys`). Done when the dotted path appears in the `configKeys` JSON or the plugin's own docs.
2. **Edit `modules/features/ai.nix`** inside the `services.hermes-agent` block (or `programs.hermes-agent` for CLI/desktop install). Secrets go to sops, never `settings`/`environment`. Done when no secret value appears in any `.nix` file.
3. **New file?** (plugin source, `SOUL.md`, `my-plugin.nix`) — `terminal(command="git add <file>")`. Done when `git status` shows it staged.
4. **Build:** `terminal(command="nh os build .", timeout=900)`. Done when it exits 0 with no assertion from `services.hermes-agent`.
5. **Switch (user-run):** NEVER run `nh os switch` or any elevating command (`run0`, `sudo`, `nixos-rebuild switch/boot/test`) from an agent session — the polkit prompt cannot be answered here and forcing elevation is forbidden. Build with `nh os build .` (step 4), then ask the user to run `nh os switch` themselves. After they've switched, restart the daemons so they reread config/`.env`: `terminal(command="systemctl --user restart hermes-backend")` (plus `hermes-agent` if `gateway.enable`). Done when both report `active (running)`.
6. **Verify** (next section), then commit with the `commit` skill (scope `features/ai`).

## Verification

```sh
# activation ran and the merge landed
journalctl -u home-manager-$USER -n 50 --no-pager | grep -i hermes
grep -n -A5 '^<top-level-key>:' ~/.hermes/config.yaml
hermes config                          # rendered view, read-only

# daemons
systemctl --user status hermes-backend hermes-agent
journalctl --user -u hermes-backend -n 100 --no-pager

# plugins
ls -la ~/.hermes/plugins/              # nix-managed-* symlinks
hermes plugins list                    # enabled / "not enabled in config" / load errors

# upstream module source at the locked rev
HERMES_SRC=$(nix eval --raw --impure --expr '(builtins.getFlake (toString ./.)).inputs.hermes-agent.outPath')
# then read_file $HERMES_SRC/nix/moduleCommon.nix (shared options), nix/homeManagerModules.nix
```

## Pitfalls

- **`.env` is rebuilt from scratch every activation** from `environment` + `environmentFiles`. Hand edits vanish. An unreadable sops path only warns (`cannot read environmentFile`) — check the activation log if keys go missing.
- **The sops secret must be `KEY=value` lines**, stored as a YAML block scalar under `hermes-agent:` — not a nested YAML map.
- **`environment` and `settings` values are world-readable** in `/nix/store`. MCP `env`/`headers` can reference `${VAR}` and resolve from `.env` at runtime — use that for tokens.
- **`documents` without `workingDirectory` fails an assertion.** The HM default is `$HOME`; the assertion checks the option was *set*, so even `workingDirectory = config.home.homeDirectory` satisfies it.
- **`SOUL.md`/`memories/` in `documents` are ignored** — they only load from `HERMES_HOME` (`hermesHomeFiles`). Note this host uses the `memory-buckets` provider with `memory_enabled = false`, so `memories/USER.md` seeds are inert anyway.
- **`hermesHomeFiles` and `documents` are reinstalled every activation**, overwriting agent edits to those files.
- **Stale imperative units.** `hermes gateway install` (pre-Nix) leaves a plain file at `~/.config/systemd/user/hermes-gateway.service` that HM doesn't own. HM's gateway unit is `hermes-agent.service`. Don't run both; `systemctl --user disable --now hermes-gateway` and delete the file when switching to `gateway.enable`.
- **`services.hermes-agent.installPackage` was removed** — the assertion message names `programs.hermes-agent.enable` as the replacement.
- **Container mode, `user`/`group`/`stateDir`, `addToSystemPackages`** are NixOS-module only; they don't exist on the HM module used here. `hermesHome` and `gateway.enable` are HM-only.
- **`backend.host` off loopback** turns on the dashboard auth gate and Host-header checks. Binding to a Tailscale name needs `backend.waitFor = "hostname"` because a user unit cannot order after `tailscaled.service`.
- **`backend.sessionTokenFile`** lets the desktop app attach to the service's backend instead of spawning its own; without it each side runs a separate backend. Must be a runtime path (sops), never a Nix path literal.
