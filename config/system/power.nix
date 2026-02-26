# power management stuff
{ config, pkgs, ... }:
{
  # power management optimisations
  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;

  # ensure conflicting power tools are disabled
  services.tlp.enable = false;
  powerManagement.powertop.enable = false;

  # power analysis tools
  environment.systemPackages = with pkgs; [
    powertop
  ];

  # enable upower service
  services.upower.enable = true;
  
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

    # explicitly enable amd p-state active mode
    "amd_pstate=active"
  ];

  services.udev.extraRules = ''
    # force my current dgpu (RX 7700S) to auto shutoff when not in use
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x7480", ATTR{power/control}="auto"

    # force WD/Sandisk NVMe ssd to sleep (enable auto power management)
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x15b7", ATTR{device}=="0x5017", ATTR{power/control}="auto"
    # force Phison NVMe ssd to sleep (enable auto power management)
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1987", ATTR{device}=="0x5021", ATTR{power/control}="auto"
  '';

  # Refresh rate monitor/adjustment service
  # Watches for power cable events via upower and switches between 60Hz (Battery) and 165Hz (AC)
  systemd.user.services.auto-rr-throttle = {
    description = "Automatically throttle max refresh rate when on battery";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];

    serviceConfig = {
      Restart = "on-failure";
      # The script monitors upower events instantly (no polling loop).
      # Currently requires existing DMS-managed display profiles
      # TODO: create display profiles declaratively
      ExecStart = pkgs.writeShellScript "rr-manager" ''
        
        # Function to apply refresh rate
        apply_rr() {
          if [ "$1" = "battery" ]; then
             echo "Switched to Battery: Setting 60Hz"
             ${pkgs.dms-shell}/bin/dms ipc call outputs setProfile "OnBattery"
          else
             echo "Switched to AC: Setting 165Hz"
             ${pkgs.dms-shell}/bin/dms ipc call outputs setProfile "OnAC"
          fi
        }

        # Initial set on startup
        STATUS=$(cat /sys/class/power_supply/ACAD/online)
        if [ "$STATUS" = "0" ]; then apply_rr "battery"; else apply_rr "ac"; fi

        # Listen for events
        ${pkgs.upower}/bin/upower --monitor | while read -r line; do
          # Trigger on line power events
          if [[ "$line" == *"line_power"* ]] || [[ "$line" == *"online:"* ]]; then
             # Tiny sleep to let hardware settle
             sleep 0.5
             NEW_STATUS=$(cat /sys/class/power_supply/ACAD/online)
             if [ "$NEW_STATUS" = "0" ]; then
               apply_rr "battery"
             else
               apply_rr "ac"
             fi
          fi
        done
      '';
    };
  };
}