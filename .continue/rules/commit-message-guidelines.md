---
description: Guidelines for git commit message generation
---

## When generating git commit messages, follow these guidelines:

### Context (Background Knowledge/Guidelines)

This is a modular NixOS configuration. Instead of a monolithic config file, each module has its own `.nix` file. This makes it easier to manage and update individual components. Commit messages are generated on a per-topic basis.

### Format

`<item>: <action>`

- `<item>` is the config item/topic that is being updated
- `<action>` describes what was done or changed in the commit

### Examples

- `networking: add compatibility mode for DNS features`:
```diff
--- a/config/networking.nix
+++ b/config/networking.nix
@@ -1,28 +1,36 @@
-{ config, pkgs, ... }:
 {
-  networking.hostName = "theseus"; # Define your hostname.
-
-  networking.networkmanager.enable = true;
-  # networking.networkmanager.dns = "none";
-  networking.nameservers = [
+  config,
+  pkgs,
+  lib,
+  ...
+}:
+let
+  # disable certain advanced features to improve network compatibility.
+  # useful if captive portals aren't resolving
+  networkCompatibilityMode = false;
+  nameservers = [
     "1.1.1.1#one.one.one.one"
     "1.0.0.1#one.one.one.one"
     "8.8.8.8"
   ];
+in
+lib.mkMerge [
+  {
+    networking.hostName = "theseus"; # Define your hostname.
+
+    networking.networkmanager.enable = true;
 
-  # Configure network proxy if necessary
-  # networking.proxy.default = "http://user:password@proxy:port/";
-  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
+    networking.nftables.enable = true;
+  }
+  # disable the following features in compat mode
+  (lib.mkIf (!networkCompatibilityMode) {
+    # networking.nameservers = nameservers;
 
-  services.resolved = {
-    enable = true;
-    dnssec = "true";
-    domains = [ "~." ];
-    fallbackDns = [
-      "1.1.1.1#one.one.one.one"
-      "1.0.0.1#one.one.one.one"
-    ];
-    dnsovertls = "true";
-  };
-  networking.nftables.enable = true;
-}
+    services.resolved = {
+      enable = true;
+      dnssec = "true";
+      domains = nameservers;
+      dnsovertls = "true";
+    };
+  })
+]
```
- `optimisations: disable gc functionality to prevent conflicts with nh clean`:
```diff
--- a/config/optimisations.nix
+++ b/config/optimisations.nix
@@ -2,11 +2,11 @@
 { config, pkgs,  ... }:
 { 
   # automatically collect garbage each week
-  nix.gc = {
-    automatic = true;
-    dates = "weekly"; # Or a specific time like "03:15"
-    options = "--delete-older-than 7d"; # Optional: delete 7 days old generations
-  };
+  # nix.gc = {
+  #   automatic = true;
+  #   dates = "weekly"; # Or a specific time like "03:15"
+  #   options = "--delete-older-than 7d"; # Optional: delete 7 days old generations
+  # };
 
   # various nix settings
   nix.settings = {

```