# System-level secrets management (sops-nix)
{ config, pkgs, ... }:

{
  sops.validateSopsFiles = false;
  sops.defaultSopsFile = "/home/coucoucl0vr/nixos-config/secrets/default.yaml";
  sops.age.sshKeyPaths = [ "/home/coucoucl0vr/.ssh/id_ed25519-age-system-theseus" ];

  sops.secrets."iwd/eduroam/passwd" = { };
}
