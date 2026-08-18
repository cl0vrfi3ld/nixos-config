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
        #
        #   Fingerprint OR password:
        #     • noctalia-lock – dedicated lock-screen service (see below)
        #     • login       – TTY login
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
          login.fprintAuth = false;
          ly.fprintAuth = false;

          # ── Fingerprint OR password ────────────────────────────────────
          polkit-1.fprintAuth = true;
          systemd-run0.fprintAuth = true;
          sudo.fprintAuth = true;

          # ── Lock screen ────────────────────────────────────────────────
          # Dedicated service for Noctalia's lock screen. Using `login`
          # causes gnome-keyring's PAM entries to interfere with the
          # conversation flow, requiring both fingerprint AND password.
          # We disable the 30s timeout and 3-try limit on pam_fprintd so
          # fingerprint auth remains continuously available while locked.
          noctalia-lock = {
            fprintAuth = true;
            rules.auth.fprintd.args = [
              "timeout=-1"
              "max-tries=-1"
            ];
          };
        };

        # Point the noctalia lock screen at our dedicated PAM service
        # instead of `login`, which has gnome-keyring entries that interfere.
        environment.sessionVariables.NOCTALIA_PAM_SERVICE = "noctalia-lock";
      };
    };
}

