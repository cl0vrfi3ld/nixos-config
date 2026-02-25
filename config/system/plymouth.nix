# plymouth splash screen config
{ pkgs, ... }: {

  boot = {

    plymouth = {
      enable = true;
      theme = "deus_ex";
      # font = "${pkgs.open-dyslexic}/share/fonts/opentype/OpenDyslexic-Regular.otf";
#       font = "${pkgs.hack-font}/share/fonts/truetype/Hack-Regular.ttf";
#       logo = "${pkgs.nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake.png";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "rings" "deus_ex" ];
        })
      ];
    };

    # silence first boot output
    consoleLogLevel = 3;
    initrd.verbose = false;
    initrd.systemd.enable = true;
    kernelParams = [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "udev.log_priority=3"
        "rd.systemd.show_status=auto"
    ];

    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;
  };
}
