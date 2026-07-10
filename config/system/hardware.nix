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

  # Power state behaviour
  # Suspend first then hibernate when closing the lid
  # services.logind.settings.Login.LidSwitch = "suspend-then-hibernate";
  # # Suspend-then-hibernate on power button pressed
  # services.logind.settings.Login.PowerKey = "suspend-then-hibernate";
  services.logind.settings.Login.PowerKeyLongPress = "poweroff";
  # Define time delay for hibernation
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "1h";
    SuspendState = "mem";
  };

  # Stuff
  hardware.enableRedistributableFirmware = true;

  # Device tweaks
  boot.kernelParams = [
    "amd_pstate=active"
    "amdgpu.abmlevel=3"
    "amdgpu.ppfeaturemask=0xffffffff"
    "usbcore.autosuspend=1"
  ];

  # Filesystem and tmp optimisations
  services.fstrim.enable = true;
  boot.tmp.useTmpfs = true;

  # Swap optimizations
  boot.zswap = {
    enable = true;
    compressor = "lz4";
  };

  # Drive mounting
  fileSystems = {
    "/too" = {
      device = "/dev/disk/by-label/data_too";
      fsType = "btrfs";
      options = [
        "nofail"
        "x-systemd.mount-timeout=5s"
      ];
    };
  };


}
