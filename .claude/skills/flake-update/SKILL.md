---
name: flake-update
description: Update flake inputs safely and report what actually changed. Use when asked to update the system, update nixpkgs, bump/upgrade inputs, pull in an upstream fix, "update my flake", or to revert an input that broke after an update.
---

# Updating flake inputs

## Pick the smallest update that does the job

**One input** — the right move when chasing a specific upstream fix. Keeps the
blast radius to one project:

```sh
nix flake update <input>          # e.g. nix flake update zen-browser
nix flake update <a> <b>          # several at once
```

**Everything:**

```sh
nix flake update
```

Be aware of the `follows` graph in `flake.nix`: nearly every input follows
`nixpkgs`, so bumping `nixpkgs` rebuilds most of the system. `nix-citizen`
additionally follows `nix-gaming`, and `dms` follows `quickshell`.

The one-shot path (`sug` / `nug` abbreviation) updates, commits the lock, and
switches in a single step:

```sh
nh os switch --update --commit-lock-file /home/coucoucl0vr/nixos-config
```

Prefer the split form below when the user wants to see what changed first, or
when a large `nixpkgs` bump is involved.

## Build before switching

```sh
nh os build .
```

Or delegate to the **Verify** agent. On failure, delegate to **Triage** — an
update failure log is usually thousands of lines with the real error buried.

Never switch on an unbuilt update.

## Report what moved

`git diff flake.lock` is unreadable noise. `nix flake update` prints a clean
`• Updated input 'x': rev (date) → rev (date)` summary — capture that output and
relay it. If the update already happened, reconstruct it:

```sh
git diff flake.lock | grep -E '^[+-]\s+"(rev|lastModified)"' 
```

Summarize which inputs actually moved and how far, not every line of the diff.
A kernel or `nixpkgs` bump is worth calling out explicitly, since it means a
reboot.

## Reverting one bad input

Do not revert the whole lockfile for one broken input. Pin that input back to
its previous rev:

```sh
git show HEAD:flake.lock > /tmp/old-lock.json     # read the old rev
```

Then either restore just that input's `locked` block in `flake.lock`, or pin it
in `flake.nix` and re-lock:

```nix
zen-browser.url = "github:0xc000022070/zen-browser-flake/<good-rev>";
```

```sh
nix flake update zen-browser
```

Rebuild and confirm before committing the pin. Leave a comment in `flake.nix`
saying why it is pinned — there is precedent for this style in the commented
`nixpkgs` pin at the top of the file.

## Commit

```
flake.lock: Update
```

Verbatim, including the capital U — that is the existing convention. If you
pinned an input in `flake.nix` as well, that is a separate commit with a real
message explaining the pin.
