# Hermes Nix option reference

Source of truth: `nix/moduleCommon.nix` (shared), `nix/homeManagerModules.nix`, `nix/nixosModules.nix` in the locked `hermes-agent` input. Get the path with:

```sh
nix eval --raw --impure --expr '(builtins.getFlake (toString ./.)).inputs.hermes-agent.outPath'
```

This repo uses the **Home Manager** module (per desktop user, via `home-manager.sharedModules`).

## `services.hermes-agent` — shared (HM + NixOS)

| Option | Type | Default | Notes |
| :--- | :--- | :--- | :--- |
| `enable` | bool | `false` | Activation (config/env/docs/plugins). Units need `gateway.enable` / `backend.mode` too on HM |
| `package` | package | flake `default` (= `full`, all extras) | Override with `hermesBase.override { … }` |
| `workingDirectory` | str | HM: `$HOME`; NixOS: `${stateDir}/workspace` | Also becomes `terminal.cwd` default and unit `WorkingDirectory=` |
| `settings` | attrs, deep-merged | `{}` | Rendered to `config.yaml` — see `settings-mapping.md` |
| `configFile` | null or path | `null` | Replaces `settings`; copied verbatim every activation |
| `environmentFiles` | list of str | `[]` | Runtime secret paths, concatenated into `.env`. `str` on purpose — a path literal would land in the store |
| `environment` | attrs of str | `{}` | Non-secret, world-readable in the store |
| `authFile` | null or path | `null` | Seeds `auth.json` if missing |
| `authFileForceOverwrite` | bool | `false` | Overwrite `auth.json` every activation |
| `documents` | attrs of (str or path) | `{}` | Installed into `workingDirectory`; asserts `workingDirectory` was set explicitly |
| `hermesHomeFiles` | attrs of (str or path) | `{}` | Installed into `HERMES_HOME` (`SOUL.md`, `memories/…`) |
| `mcpServers.<n>` | submodule | `{}` | See below |
| `extraPackages` | list of package | `[]` | On unit PATH; also `home.packages` when `programs.hermes-agent.enable` |
| `extraPlugins` | list of package | `[]` | Each needs root `plugin.yaml`; unique `lib.getName` asserted |
| `extraPythonPackages` | list of package | `[]` | Entry-point plugins / plugin deps. **Broken pending upstream PR #129837** — see SKILL.md |
| `extraDependencyGroups` | list of str | `[]` | pyproject extras. Setting it re-overrides `package` with *only* these groups |
| `extraArgs` | list of str | `[]` | Appended to `hermes gateway` |
| `restart` / `restartSec` | str / int | `"always"` / `5` | systemd `Restart=` / `RestartSec=` |
| `backend.mode` | `"none"`/`"serve"`/`"dashboard"` | `"none"` | `hermes serve`/`dashboard` unit (`hermes-backend`) |
| `backend.host` | str | `"127.0.0.1"` | Non-loopback → auth gate + Host-header pinning |
| `backend.port` | port | `9119` | |
| `backend.waitFor` | null/`"hostname"`/`"interface"` | `null` | Poll for bind target (user units can't order after system units) |
| `backend.interfaceName` | null or str | `null` | Required iff `waitFor = "interface"` (asserted both ways) |
| `backend.waitTimeout` | positive int | `120` | Seconds; fails rather than falling back |
| `backend.extraArgs` | list of str | `[]` | |
| `backend.sessionTokenFile` | null or str | `null` | Raw token, mode 0600, runtime path. Lets desktop share the service backend |

### `mcpServers.<name>`

| Field | Type | Default | Notes |
| :--- | :--- | :--- | :--- |
| `command` / `args` / `env` | str / list / attrs | `null` / `[]` / `{}` | stdio transport. `env` values may use `${VAR}` from `.env` |
| `url` / `headers` | str / attrs | `null` / `{}` | HTTP/StreamableHTTP. `headers.Authorization = "Bearer \${TOKEN}";` |
| `auth` | null or `"oauth"` | `null` | OAuth 2.1 PKCE; tokens in `$HERMES_HOME/mcp-tokens/<name>.json`. First run needs interactive `hermes mcp add … --auth oauth` |
| `enabled` | bool | `true` | |
| `timeout` / `connect_timeout` | null or int | `null` (120 / 60 at runtime) | seconds |
| `tools.include` / `tools.exclude` | list of str | `[]` | |
| `sampling.{enabled,model,max_tokens_cap,timeout,max_rpm,max_tool_rounds,allowed_models,log_level}` | — | `null` | Server-initiated LLM calls |

Escape the `${` so Nix doesn't interpolate: `"\${GITHUB_TOKEN}"` in double-quoted strings, `''${GITHUB_TOKEN}` inside `''…''` strings.

## Home Manager only

| Option | Type | Default | Notes |
| :--- | :--- | :--- | :--- |
| `services.hermes-agent.hermesHome` | str | `~/.hermes` | `HERMES_HOME` directly |
| `services.hermes-agent.gateway.enable` | bool | `false` | `systemd.user.services.hermes-agent` (messaging gateway) |
| `programs.hermes-agent.enable` | bool | `false` | `hermes` on PATH + `HERMES_HOME` in `home.sessionVariables` (shells only, not GUI launchers) |
| `programs.hermes-agent.package` | package | services' effective package | One build for CLI + daemons |
| `programs.hermes-agent.desktop.enable` | bool | `false` | Electron app; launcher carries `HERMES_HOME`, `HERMES_MANAGED`, and remote backend URL/token when `sessionTokenFile` is set |
| `programs.hermes-agent.desktop.package` | package | `package.hermesDesktop` | |

Removed: `services.hermes-agent.installPackage` (assertion names the replacement).

## NixOS module only (not used here)

`user`, `group`, `createUser` (sets `linger`), `stateDir` (`/var/lib/hermes`, `HERMES_HOME = ${stateDir}/.hermes`), `addToSystemPackages`, `container.{enable,backend,image,extraVolumes,extraOptions,hostUsers}`. Container mode can't be combined with `backend.mode`. Gateway is the service itself, so no `gateway.enable`.

## Units and files (HM, Linux)

| Thing | Location |
| :--- | :--- |
| Gateway unit | `systemd --user` `hermes-agent.service` (if `gateway.enable`) |
| Backend unit | `systemd --user` `hermes-backend.service` (if `backend.mode != "none"`) |
| Activation | `home.activation.hermesAgentSetup` → runs inside `home-manager-<user>.service` on `nh os switch` |
| Unit env | `HERMES_HOME`, `HERMES_MANAGED=home-manager`, PATH = package + bash + coreutils + git + `extraPackages`; `UMask=0077`, `NoNewPrivileges`, `PrivateTmp` |
| State | `~/.hermes/{config.yaml,.env,.managed,auth.json,SOUL.md,memories,sessions,skills,cron,logs,plugins,mcp-tokens}` — files mode 0600 |

## Flake outputs worth knowing

| Output | Use |
| :--- | :--- |
| `packages.<sys>.default` | `full` — all portable extras (anthropic, azure-identity, bedrock, daytona, dingtalk, edge-tts, exa, fal, feishu, firecrawl, honcho, messaging, modal, parallel-web, tts-premium, vercel, voice, + matrix on Linux) |
| `packages.<sys>.minimal` / `.messaging` | Smaller closures |
| `packages.<sys>.desktop` / `.tui` / `.web` | Passthru frontends |
| `packages.<sys>.configKeys` | JSON list of valid leaf config keys |
| `packages.<sys>.pm-<name>` | Pinned runtime tool archives |
| `overlays.default` | `pkgs.hermes-agent` |
| `checks.<sys>.{package-contents,entry-points-sync,cli-commands,managed-guard,bundled-skills,config-roundtrip}` | Upstream CI |
| `<pkg>.python`, `<pkg>.hermesVenv`, `<pkg>.hermesDesktop` | Passthrus for building plugins / frontends |
