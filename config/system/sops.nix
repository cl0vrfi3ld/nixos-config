# system-level flatpak config
{ config, pkgs, ... }:

{
  # sops config
  sops.validateSopsFiles = false;
  sops.defaultSopsFile = "/home/coucoucl0vr/nixos-config/secrets/default.yaml";
  # This will automatically import SSH keys as age keys
  sops.age.sshKeyPaths = [ "/home/coucoucl0vr/.ssh/id_ed25519-age-system-theseus" ];

  # include the iwd secrets
  sops.secrets."iwd/eduroam/passwd" = {};
}
