# System-level hardware configuration (power, graphics, audio, bluetooth)
{
  pkgs,
  system,
  inputs,
  ...
}:

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

  services.upower.enable = true;
  hardware.acpilight.enable = true;

  # Device tweaks
  boot.kernelParams = [
    "amd_pstate=active"
    "amdgpu.abmlevel=3"
    "amdgpu.ppfeaturemask=0xffffffff"
    # "usbcore.autosuspend=1"
  ];

  # Refresh rate monitor
  systemd.user.services.auto-rr-throttle = {
    description = "Automatically throttle max refresh rate when on battery";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    path = [
      inputs.quickshell.packages.${system}.quickshell
      pkgs.dms-shell
    ];
    serviceConfig = {
      Restart = "on-failure";
      # Currently requires existing DMS-managed display profiles
      # TODO: create display profiles declaratively
      ExecStart = pkgs.writeShellScript "rr-manager" ''
        apply_rr() {
          if [ "$1" = "battery" ]; then
             echo "Switched to Battery: Setting 60Hz"
             dms ipc call outputs setProfile OnBattery
          else
             echo "Switched to AC: Setting 165Hz"
             dms ipc call outputs setProfile OnAC
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

  # Drive mounting
  fileSystems = {
    "/too" = {
      device = "/dev/disk/by-label/data_too";
      fsType = "btrfs";
    };
  };
}
