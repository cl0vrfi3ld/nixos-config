{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.sops =
    {
      config,
      pkgs,
      ...
    }:
    {
      # SOPS config
      sops.validateSopsFiles = false;
      sops.defaultSopsFile = "/home/coucoucl0vr/nixos-config/secrets/default.yaml";
      sops.age.sshKeyPaths = [ "/home/coucoucl0vr/.ssh/id_ed25519-age-system-theseus" ];
      # iwd eduroam password
      sops.secrets."iwd/eduroam/passwd" = { };

      # General Secrets Management and Utils
      environment.systemPackages = with pkgs; [
        age
        libsecret
      ];
    };
}
