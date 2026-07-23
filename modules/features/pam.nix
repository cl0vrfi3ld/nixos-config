{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.pam =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.features.pam;
    in
    {
      options.features.pam = {
        fingerprint.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable fprintd fingerprint authentication (disabled for the ly greeter).";
        };
      };

      config = {
        # Fingerprint policy:
        #  - `ly` greeter (boot / new session) -> password only, no fingerprint
        #  - noctalia lock screen unlock        -> fingerprint OR password
        #    (noctalia auto-detects the `login` PAM service, which keeps fprintd
        #     enabled by default because services.fprintd.enable = true)
        services.fprintd.enable = lib.mkIf cfg.fingerprint.enable true;
        security.pam.services.ly.fprintAuth = lib.mkIf cfg.fingerprint.enable false;

        # Pin the noctalia lock screen to the `login` PAM service explicitly, instead
        # of relying on its runtime probe, so unlock behavior stays deterministic.
        environment.sessionVariables.NOCTALIA_PAM_SERVICE = "login";
      };
    };
}
