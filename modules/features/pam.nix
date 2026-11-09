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
          description = "Enable fprintd fingerprint authentication.";
        };
      };

      config = {
        # ── fprintd service ──────────────────────────────────────────────
        services.fprintd.enable = lib.mkIf cfg.fingerprint.enable true;

        # ── Fingerprint policy (per PAM service) ─────────────────────────
        # services.fprintd.enable = true sets the *default* fprintAuth for every
        # PAM service to true.  We override that default explicitly on every
        # service we care about so the policy is self-documenting and won't
        # silently change when new services appear.
        #
        #   Password ONLY (no fingerprint):
        #     • ly          – greeter at boot / first login
        #     • login       – TTY login; also Noctalia's lock screen password
        #                     path (see below)
        #
        #   Fingerprint OR password:
        #     • Noctalia lock screen – password via `login`, fingerprint driven
        #                     by Noctalia itself over fprintd's D-Bus API
        #     • polkit-1    – GUI privilege-escalation prompts
        #     • systemd-run0 – run0 CLI privilege escalation (used by nh)
        #     • sudo        – sudo, if ever re-enabled
        #
        #   gnome-keyring: inherently password-only (needs the password to
        #   derive its decryption key); no PAM override needed.
        security.pam.services = lib.mkIf cfg.fingerprint.enable {
          # ── Password only ──────────────────────────────────────────────
          # Note: ly delegates to the `login` PAM service (`auth substack login`),
          # so `login.fprintAuth` must be false for ly to be password-only.
          # Noctalia v5 hardcodes `login` for its lock screen and needs
          # pam_fprintd kept out of it, since it claims the reader itself.
          login.fprintAuth = false;
          ly.fprintAuth = false;

          # ── Fingerprint OR password ────────────────────────────────────
          polkit-1.fprintAuth = true;
          systemd-run0.fprintAuth = true;
          sudo.fprintAuth = true;
        };
      };
    };
}
