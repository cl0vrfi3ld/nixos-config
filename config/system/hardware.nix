{ config, pkgs, ... }:

{
  # Framework specific stuff
  hardware.framework.enableKmod = true;

  # Graphics configuration
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    libva
  ];

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Sound with Pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Printing
  services.printing.enable = true;

  # Power Management
  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;
  powerManagement.powertop.enable = false;

  environment.systemPackages = with pkgs; [
    powertop
  ];

  services.upower.enable = true;
  hardware.acpilight.enable = true;

  # Device tweaks
  boot.kernelParams = [
    "amdgpu.abmlevel=3"
    "amdgpu.ppfeaturemask=0xffffbfff"
    "pcie_port_pm=force"
    "pcie_aspm.policy=powersupersave"
    "usbcore.autosuspend=1"
    "amd_pstate=active"
  ];

  services.udev.extraRules = ''
    # force my current dgpu (RX 7700S) to auto shutoff when not in use
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x7480", ATTR{power/control}="auto"

    # force WD/Sandisk NVMe ssd to sleep
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x15b7", ATTR{device}=="0x5017", ATTR{power/control}="auto"
    # force Phison NVMe ssd to sleep
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1987", ATTR{device}=="0x5021", ATTR{power/control}="auto"
  '';

  # Refresh rate monitor
  systemd.user.services.auto-rr-throttle = {
    description = "Automatically throttle max refresh rate when on battery";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];

    serviceConfig = {
      Restart = "on-failure";
      # Currently requires existing DMS-managed display profiles
      # TODO: create display profiles declaratively
      ExecStart = pkgs.writeShellScript "rr-manager" ''
        apply_rr() {
          if [ "$1" = "battery" ]; then
             echo "Switched to Battery: Setting 60Hz"
             ${pkgs.dms-shell}/bin/dms ipc call outputs setProfile "OnBattery"
          else
             echo "Switched to AC: Setting 165Hz"
             ${pkgs.dms-shell}/bin/dms ipc call outputs setProfile "OnAC"
          fi
        }

        STATUS=$(cat /sys/class/power_supply/ACAD/online)
        if [ "$STATUS" = "0" ]; then apply_rr "battery"; else apply_rr "ac"; fi

        ${pkgs.upower}/bin/upower --monitor | while read -r line; do
          if [[ "$line" == *"line_power"* ]] || [[ "$line" == *"online:"* ]]; then
             sleep 0.5
             NEW_STATUS=$(cat /sys/class/power_supply/ACAD/online)
             if [ "$NEW_STATUS" = "0" ]; then apply_rr "battery"; else apply_rr "ac"; fi
          fi
        done
      '';
    };
  };

  # Filesystem and tmp optimisations
  services.fstrim.enable = true;
  boot.tmp.useTmpfs = true;
}
