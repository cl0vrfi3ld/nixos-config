{
  pkgs,
  inputs,
  system,
  ...
}:
# let
#   # zen-browser-twilight = inputs.zen-browser.packages."${system}".twilight.override {
#   #   policies = {

#   # };
# in
{
  home.packages = with pkgs; [
    mullvad-browser
    librewolf
    nextcloud-client
  ];
  # enable and configure zen browser
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
  # we've migrated! suppress the migration warning
  programs.zen-browser.suppressXdgMigrationWarning = true;
}
