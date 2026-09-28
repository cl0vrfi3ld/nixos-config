---
name: flake-update
description: "Update flake inputs safely and report changes."
version: 0.1.0
author: Ivy (coucoucl0vr), Hermes Agent
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [nixos, flakes, updates, lockfile]
    related_skills: [rescue, commit]
---

# Updating Flake Inputs

## When to Use

- Updating flake inputs (all or single target)
- Bumping inputs to pull an upstream fix
- Reverting a broken flake input update
- Don't use for: local module edits without input changes

## Single Input Update

Prefer single-input updates to keep changes isolated:

```sh
nix flake update <input>          # e.g. nix flake update zen-browser
```

## Full System Update

Update all inputs:

```sh
nix flake update
```

One-shot build and switch abbreviation (`sug` / `nug`):
```sh
nh os switch --update --commit-lock-file /home/coucoucl0vr/nixos-config
```

## Reverting a Broken Input

Inspect previous revision:
```sh
git show HEAD:flake.lock > /tmp/old-lock.json
```

Pin the specific input in `flake.nix`:
```nix
zen-browser.url = "github:0xc000022070/zen-browser-flake/<good-rev>";
```
Then re-lock: `nix flake update zen-browser`.

## Commit Convention

Commit lockfile bumps with exact scope and summary:
```
flake.lock: Update
```

## Pitfalls

- Most inputs follow `nixpkgs`. Bumping `nixpkgs` rebuilds almost the entire system.
- Never switch on an unbuilt flake update. Run `nh os build .` first.
