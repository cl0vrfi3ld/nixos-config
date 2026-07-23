# System-level security and polkit configuration
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Enable polkit
  security.polkit.enable = true;
  # Enable gnome-keyring
  services.gnome.gnome-keyring.enable = true;
  # Enable fprintd
  services.fprintd.enable = true;
  # TOD didn't fix the issue
  # services.fprintd.tod = {
  #   enable = true;
  #   driver = pkgs.libfprint-2-tod1-goodix;
  # };

  # Fingerprint policy:
  #  - `ly` greeter (boot / new session) -> password only, no fingerprint
  #  - noctalia lock screen unlock        -> fingerprint OR password
  #    (noctalia auto-detects the `login` PAM service, which keeps fprintd
  #     enabled by default because services.fprintd.enable = true)
  security.pam.services.ly.fprintAuth = false;

  # Pin the noctalia lock screen to the `login` PAM service explicitly, instead
  # of relying on its runtime probe, so unlock behavior stays deterministic.
  environment.sessionVariables.NOCTALIA_PAM_SERVICE = "login";
}
