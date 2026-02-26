# desktop interface config
{ inputs, pkgs, system, ... }:

{
  # import DankMaterialShell plugin registry
  imports = [ inputs.dms-plugin-registry.modules.default ];
  
  # enable niri
  programs.niri.enable = true;
  # enable Dank Material Shell
  programs.dms-shell = {
    enable = true;
    
    quickshell.package = inputs.quickshell.packages.${system}.quickshell;
    
    systemd = {
      enable = true; # Systemd service for auto-start
      restartIfChanged = true; # Auto-restart dms.service when dms-shell changes
    };

    # Core features
    enableSystemMonitoring = true; # System monitoring widgets (dgop)
    enableVPN = true; # VPN management widget
    enableDynamicTheming = true; # Wallpaper-based theming (matugen)
    enableCalendarEvents = true; # Calendar integration (khal)
    enableClipboardPaste = true; # Pasting from the clipboard history (wtype)
  };
  # dms plugins
  programs.dms-shell.plugins = {
      dankBatteryAlerts.enable = true;
      dankKDEConnect.enable = true;
    };
  # enable DankSearch
  programs.dsearch.enable = true;
  # include Niri and DankMaterialShell packages
  environment.systemPackages = with pkgs; [xwayland-satellite dgop kdePackages.kimageformats];
  # enable accounts daemon
  services.accounts-daemon.enable = true;
}
