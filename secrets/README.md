# Put secret config stuff here

it won't be committed to the git repo

Also, this document provides a guide on how to manage secrets in this NixOS configuration using SOPS (Secrets OPerationS) and the `sops-nix` integration.

## 1. Overview

[SOPS](https://github.com/mozilla/sops) is a powerful tool for encrypting and decrypting files containing structured data like YAML or JSON. It integrates with various encryption providers, and is the foundation of our secrets management strategy.

[sops-nix](httpss://github.com/Mic92/sops-nix) is a NixOS module that allows you to declaratively manage secrets encrypted with SOPS. It decrypts secrets at build time and makes them available to the system in a secure manner.

## 2. Prerequisites

Before you can manage secrets, you need to have the following set up:

-   A GPG key pair generated and configured on your system.
-   The public key of any other users who need to access the secrets.

You can generate a GPG key by running:
```bash
gpg --full-generate-key
```

## 3. Configuring SOPS

The `.sops.yaml` file in the root of this repository is the primary configuration file for SOPS. It specifies which GPG keys are allowed to decrypt the secrets.

To add a new user, you need to:
1.  Import their GPG public key.
2.  Add their GPG key fingerprint to the `pgp` section of the `.sops.yaml` file.

## 4. Editing Secrets

To edit secrets, you will use the `sops` command-line tool. It will automatically open the encrypted file in your default editor, and will re-encrypt it when you are done.

To edit a secrets file, run:
```bash
sops secrets/default.yaml
```

**Note:** The `sops` command is NOT available in the Nix shell by default. You may open a shell with the required cli tool using `nix shell nixpkgs#sops`

## 5. Adding New Secrets

To add a new secret:
1.  Open the `secrets/default.yaml` file using the `sops` command.
2.  Add your new secret in YAML format.
3.  Save and close the file. SOPS will automatically re-encrypt it.

## 6. Accessing Secrets in NixOS

The `sops-nix` module makes your secrets available within your NixOS configuration. In this project, the secrets are configured in `config/sops.nix`.

To access a secret, you need to add an entry to the `sops.secrets` attribute set. For example, to make the `iwd/eduroam/passwd` secret available to the system, the following is added to `config/sops.nix`:

```nix
sops.secrets."iwd/eduroam/passwd" = {};
```

This will make the decrypted secret available at `/run/secrets/iwd/eduroam/passwd`. You can then configure your applications to read from that file.

For more advanced usage and configuration options, please refer to the official [sops-nix documentation](https.github.com/Mic92/sops-nix).
