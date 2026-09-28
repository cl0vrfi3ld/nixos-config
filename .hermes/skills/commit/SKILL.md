---
name: commit
description: "Commit NixOS config changes using scope-prefixed messages."
version: 0.1.0
author: Ivy (coucoucl0vr), Hermes Agent
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [nixos, git, commit, conventions]
    related_skills: [add-feature, add-package]
---

# Committing in nixos-config

## When to Use

- Staging and committing changes in this repository
- Checking for untracked `.nix` files before building or committing
- Formatting commit messages to match repo convention
- Don't use for: unprompted commits (only commit when requested)

## Message Convention

```
<scope>: <lowercase imperative summary>
```

Scope rules:
- `modules/features/<name>.nix` → `features/<name>`
- `modules/packages/<name>.nix` → `packages/<name>`
- `modules/hosts/TheUnreliable/*` → `hosts/TheUnreliable`
- `flake.lock` only → `flake.lock: Update` (exact capitalization)
- Cross-cutting changes → bare imperative (`refactor: ...` or `move everything to dendritic`)

Examples from history:
```
features/user-apps: add openwork package
features/nh: auto optimise store and don't auto clean direnv
hosts/TheUnreliable: enable programs.fuse.userAllowOther
features/pam: fix pam modules
flake.lock: Update
```

## Pre-commit Verification

Always check for untracked files:
```sh
terminal(command="git status --short")
```

Flakes ignore untracked files. Any `.nix` file with `??` must be staged (`git add <file>`) or Nix will evaluate without it.
Never commit decrypted secrets. Only SOPS-encrypted `secrets/default.yaml` is tracked.

## Pitfalls

- Omitting the scope prefix or using capitalized summaries violates repository history conventions.
- Uncommitted working trees are normal during testing; do not commit unless explicitly requested.
