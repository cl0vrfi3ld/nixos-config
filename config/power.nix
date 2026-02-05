# power management stuff
{ config, pkgs, ... }:
{
  # power management optimisations
  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;

  # ensure conflicting power tools are disabled
  services.tlp.enable = false;
  powerManagement.powertop.enable = false;

  # add powertop analysis tool to system packages
  environment.systemPackages = with pkgs; [
    powertop
  ];
  
  # enable auto backlight management
  hardware.acpilight.enable = true;

  # device tweaks
  boot.kernelParams = [
    # enable adaptive backlight management (ABM)
    "amdgpu.abmlevel=3"

    # allow power profile control of gpu while keeping overdrive and other troublemakers disabled
    "amdgpu.ppfeaturemask=0xffffbfff"

    # force Active State Power Management (APSM)
    "pcie_port_pm=force"
    "pcie_aspm.policy=powersupersave"

    # force usb autosuspend
    "usbcore.autosuspend=1"
  ];
  services.udev.extraRules = ''
    # force my current dgpu (RX 7700S) to auto shutoff when not in use
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x7480", ATTR{power/control}="auto"

    # force WD/Sandisk NVMe ssd to sleep (enable auto power management)
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x15b7", ATTR{device}=="0x5017", ATTR{power/control}="auto"
    # force Phison NVMe ssd to sleep (enable auto power management)
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1987", ATTR{device}=="0x5021", ATTR{power/control}="auto"
  '';

  # # refresh rate monitor/adjustment service (wip, CURRENTLY ONLY SUPPORTS KDE):
  # # this is a utiity service that watches the current power state (plugged in/on battery) and sets the refresh
  # # rate cap for the display according to the state. it updates every 15 seconds for maximum efficiency
  # # must be enabled for each user
  # # plugged in = max 165 hz | on battery = max 60 hz
  # systemd.user.services.auto-rr-throttle = {
  #   description = "Automatically throttle max refresh rate when on battery";
  #   after = [ "graphical-session.target" ];
  #   partOf = [ "graphical-session.target" ];
  #   wantedBy = [ "graphical-session.target" ];
  #   # permit a max of 5 restarts within a 10 min period
  #   unitConfig = {
  #     StartLimitBurst = 5;
  #     StartLimitIntervalSec = 600;
  #   };

  #   serviceConfig = {
  #     Restart = "on-failure";
  #     RestartSec = 30; # wait 30 secs before restarting
  #     # "pre-flight" check
  #     ExecCondition = pkgs.writeShellScript "rr-preflight" ''
  #       # skip running the service if the DE/WM is incompatible
  #       if [ "$XDG_CURRENT_DESKTOP" != "KDE" ]; then
  #         echo "WARN: Current desktop is $XDG_CURRENT_DESKTOP, not KDE. Skipping..."
  #         exit 1
  #       fi
  #     '';
  #     # le service script
  #     ExecStart = pkgs.writeShellScript "rr-manager" ''
  #       # constants (TODO: move these into nix options):
  #       # this file will output a 0 if device is unplugged, or 1 if plugged in
  #       AC_STATE_PATH="/sys/class/power_supply/ACAD/online"
  #       # how long to wait (in seconds) between status updates
  #       UPDATE_INTERVAL=15
  #       # the display to target
  #       TARGET_DISPLAY="eDP-2"
  #       # the resolution to use
  #       BASE_RESOLUTION="2560x1600"
  #       # the high and low power refresh rates
  #       RR_HIGH=165
  #       RR_LOW=60

  #       # state vars:
  #       # global "last state" to compare against when checking for updates
  #       PREV_STATE=""

  #       # helper function for setting the RR (currently kde only)
  #       apply_rr() {
  #         # function parameter
  #         TARGET_HZ=$1
  #         echo "Setting refresh rate to ''${TARGET_HZ}Hz..."
  #         ${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.''${TARGET_DISPLAY}.mode.''${BASE_RESOLUTION}@$TARGET_HZ
  #       }

  #       # main logic loop
  #       while true; do
  #         # fetch new status
  #         NEW_STATE=$(cat $AC_STATE_PATH)

  #         # only do stuff if the state has actually changed
  #         if [ "$NEW_STATE" != "$PREV_STATE" ]; then
  #           case "$NEW_STATE" in
  #             # device is unplugged, lower refresh rate
  #             0)
  #               echo "Status: Device is unplugged, lowering refresh rate"
  #               apply_rr $RR_LOW
  #               ;;
            
  #             # device is plugged in, increase refresh rate
  #             1)
  #               echo "Status: Device is connected to external power, increasing refresh rate"
  #               apply_rr $RR_HIGH
  #               ;;
  #           esac
  #           PREV_STATE="$NEW_STATE"
  #         fi
  #         sleep $UPDATE_INTERVAL
  #       done
  #     '';
  #   };
  # };

  # enable the service
  # systemd.services.auto-rr-throttle.enable = true;
}
