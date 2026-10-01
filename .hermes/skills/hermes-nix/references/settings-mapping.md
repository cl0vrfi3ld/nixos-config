# `services.hermes-agent.settings` ↔ `config.yaml`

`settings` is a free-form attrset rendered 1:1 to `~/.hermes/config.yaml`. Nested YAML mappings become nested attrsets; Nix dotted attribute paths are just shorthand for nesting.

## Type mapping

| YAML | Nix | Notes |
| :--- | :--- | :--- |
| `key: value` mapping | `{ key = value; }` or `key = value;` | `a.b.c = 1;` ≡ `a = { b = { c = 1; }; };` |
| string | `"text"` | Quote anything YAML would coerce (`"on"`, `"0755"`, version-like strings) — Nix strings stay strings |
| integer / float | `180` / `0.85` | Nix has no `1e3` literal; write `1000` |
| bool `true`/`yes`/`on` | `true` | Output is JSON, so always `true`/`false` |
| `null` / `~` | `null` | Sets the key to null on disk; it does **not** delete it |
| list | `[ "a" "b" ]` | No commas in Nix lists |
| list of mappings | `[ { matcher = "x"; command = "y"; } ]` | e.g. `hooks.<event>` |
| key containing `-`, `.`, `/` or starting with a digit | `"my-key" = …;` / `plugins."cat/name" = …;` | Unquoted `memory-buckets` works as an identifier in Nix; quote when in doubt |
| multi-line string `|` | `''…''` | Nix strips common leading indentation |

## Translations

`hermes config set <dotted.key> <value>` → `settings.<dotted.key> = <value>;`

```yaml
# config.yaml
model:
  default: anthropic/claude-sonnet-4
  provider: anthropic
display:
  interface: tui
  show_reasoning: true
compression:
  enabled: true
  threshold: 0.85
toolsets: [all]
skills:
  trusted_project_dirs:
    - /home/coucoucl0vr/nixos-config
plugins:
  enabled: [hermes-lcm]
  memory-buckets:
    prefetch_min_similarity: 0.35
```

```nix
settings = {
  model = {
    default = "anthropic/claude-sonnet-4";
    provider = "anthropic";
  };
  display = {
    interface = "tui";
    show_reasoning = true;
  };
  compression = {
    enabled = true;
    threshold = 0.85;
  };
  toolsets = [ "all" ];
  skills.trusted_project_dirs = [ "/home/coucoucl0vr/nixos-config" ];
  plugins = {
    enabled = [ "hermes-lcm" ];
    memory-buckets.prefetch_min_similarity = 0.35;
  };
};
```

## Keys with dedicated options — prefer these over raw `settings`

| `config.yaml` / file | Nix option | Why |
| :--- | :--- | :--- |
| `mcp_servers.<name>` | `mcpServers.<name>` | Typed submodule; null/empty fields dropped. Merged into `settings.mcp_servers` |
| `terminal.cwd` | `workingDirectory` (also sets the unit's `WorkingDirectory=`) | Injected as default; explicit `settings.terminal.cwd` wins |
| `.env` | `environmentFiles` (secrets) / `environment` (non-secret) | `.env` is rewritten each activation |
| `auth.json` | `authFile` (+ `authFileForceOverwrite`) | Only seeded if absent |
| `SOUL.md`, `memories/*` | `hermesHomeFiles` | Must live in `HERMES_HOME` |
| `AGENTS.md` etc. in workspace | `documents` | Needs explicit `workingDirectory` |
| `plugins/<dir>` | `extraPlugins` | Symlinked as `nix-managed-<name>` |
| whole file | `configFile` | Replaces `settings`, no merge, clobbers runtime edits |

## Merge semantics (activation-time)

`deep_merge(existing_on_disk, nix)`:

- both sides mappings → recurse
- otherwise → **Nix value replaces** disk value (lists, scalars, null, mapping-vs-scalar)
- keys only on disk → kept
- keys only in Nix → added

So:

| Situation | Result |
| :--- | :--- |
| Nix sets `display.interface`, disk has `display.skin` from TUI | both kept |
| Nix sets `plugins.enabled = [ "a" ]`, disk has `[ "a" "b" ]` | `[ "a" ]` — `b` disabled |
| Remove `tts` block from Nix | `tts` block stays on disk unchanged |
| Nix sets `foo = null` | `foo: null` on disk |
| Two modules set `settings.toolsets` | last-evaluated wins (recursiveUpdate), no list concat |

Eval-time merge across modules is `lib.foldl' lib.recursiveUpdate {}` over all definitions — same rules, ordering follows module definition order. Use `lib.mkMerge`/`lib.mkIf` freely inside `settings`; avoid `lib.mkForce` on `settings` itself (it drops every other definition wholesale).

## Discovering keys

```sh
nix build --no-link --print-out-paths --inputs-from . hermes-agent#configKeys
```

Prints a store path holding a sorted JSON list of every leaf path in `DEFAULT_CONFIG` at the **locked** rev (~930 keys). Caveats:

- Leaves only. Dict-valued sections with an empty default appear as a single leaf (`hooks`, `personalities`, `quick_commands`, `platform_hints`, `model`) — their inner shape comes from docs.
- Keys deliberately omitted from defaults won't appear: `plugins.enabled`, `plugins.disabled`, `plugins.<plugin-name>.*`, `mcp_servers.*`, `memory.<provider>.*`.
- Top-level sections at this rev: agent approvals attachments auth auxiliary bedrock browser checkpoints code_execution compression computer_use context cron curator dashboard delegation desktop discord display fallback gateway goals kanban logging lsp matrix mcp memory model_catalog network onboarding openrouter plugins privacy prompt_caching proxy secrets security session sessions skills slack streaming stt telegram terminal tools tts updates vault vision voice web, plus top-level `toolsets`, `fallback_providers`, `command_allowlist`, `hooks`, `personalities`, `quick_commands`, `platform_hints`.

Cross-check a live result with `hermes config` (read-only) or `read_file ~/.hermes/config.yaml`.
