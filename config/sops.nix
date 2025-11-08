# system-level flatpak config
{ config, pkgs, ... }:

{
  # sops config
  sops.defaultSopsFile = ./secrets/default.yaml;
  # This will automatically import SSH keys as age keys
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # include the iwd secrets
  sops.secrets."iwd/eduroam/passwd" = {};
}
