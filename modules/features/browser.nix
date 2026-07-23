{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.browser =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      config = {
        home-manager.sharedModules = [ inputs.zen-browser.homeModules.twilight ];

        home-manager.users = self.lib.applyDesktopHome config (username: {
          # Zen Browser
          programs.zen-browser.enable = true;
          programs.zen-browser.policies = {
            AutofillAddressEnabled = false;
            AutofillCreditCardEnabled = false;
            DisableAppUpdate = true;
            DisableFeedbackCommands = true;
            DisableFirefoxStudies = true;
            DisablePocket = true;
            DisableTelemetry = true;
            DontCheckDefaultBrowser = true;
            NoDefaultBookmarks = true;
            OfferToSaveLogins = false;
            EnableTrackingProtection = {
              Value = true;
              Locked = false;
              Cryptomining = true;
              Fingerprinting = true;
            };
          };
        });
      };
    };
}
