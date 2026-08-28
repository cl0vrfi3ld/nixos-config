---
name: commit
description: Commit changes to this NixOS config using the repo's scope-prefixed message convention. Use when asked to commit, stage, or write a commit message here - and always before committing, to catch untracked .nix files that would silently break flake evaluation.
---

# Committing in this repo

## Message format

```
<scope>: <lowercase imperative summary>
```

Scope mirrors the path that changed:

| Change | Scope |
| :--- | :--- |
| `modules/features/user-apps.nix` | `features/user-apps` |
| `modules/features/noctalia/theming.nix` | `features/noctalia` |
| `modules/packages/openwork.nix` | `packages/openwork` |
| `modules/hosts/TheUnreliable/*` | `hosts/TheUnreliable` |
| `flake.lock` only | `flake.lock: Update` |

Real examples from this history:

```
features/user-apps: add openwork package
features/nh: auto optimise store and don't auto clean direnv
hosts/TheUnreliable: enable programs.fuse.userAllowOther
features/pam: fix pam modules
flake.lock: Update
```

`flake.lock: Update` is the one fixed, capitalized exception — reproduce it
verbatim so lockfile bumps stay greppable.

Summary line only. No body unless the change genuinely needs explaining, and
no "Generated with" footer — this history has none of that. (Claude Code
appends its own `Co-Authored-By` / `Claude-Session` trailers; that is a harness
requirement and is expected.)

If a change spans several modules with no single scope, use a bare summary
(`refactor`, `move everything to dendritic`) rather than inventing a compound
scope.

## Before every commit

```sh
git status --short
```

Look for `??` entries. **An untracked `.nix` file or asset under `modules/` is
a correctness bug, not untidiness** — flakes only evaluate tracked files, so an
unstaged module silently does nothing while the build still passes. Stage
anything the config references.

`secrets/*` is gitignored except `default.yaml` and `README.md`. Never commit a
decrypted secret; only the SOPS-encrypted `secrets/default.yaml` belongs in git.

## Scope of the commit

Commit only what was asked for. Changes here are activated, not merged, so an
uncommitted working tree is a normal state — do not commit unprompted, and do
not push or branch unless asked.
