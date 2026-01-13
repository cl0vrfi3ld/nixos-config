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

  # device tweaks
  boot.kernelParams = [
    # allow power profile control of gpu while keeping overdrive and other troublemakers disabled
    "amdgpu.ppfeaturemask=0xffffbfff"

    # force Active State Power Management (APSM)
    "pcie_port_pm=force"
    "pcie_aspm.policy=powersupersave"

    # force usb autosuspend
    "usbcore.autosuspend=1"
  ];

  # 4. Udev Rules
  services.udev.extraRules = ''
    # force my current dgpu (RX 7700S) to auto shutoff when not in use
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x7480", ATTR{power/control}="auto"

    # force WD/Sandisk NVMe ssd to sleep (enable auto power management)
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x15b7", ATTR{device}=="0x5017", ATTR{power/control}="auto"
    # force Phison NVMe ssd to sleep (enable auto power management)
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1987", ATTR{device}=="0x5021", ATTR{power/control}="auto"
  '';
}
