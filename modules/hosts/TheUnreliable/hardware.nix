{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.TheUnreliable-hardware =
    {
      config,
      pkgs,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-amd" ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/423e0974-fb4f-4e4d-8e61-78213584088b";
        fsType = "ext4";
      };

      boot.initrd.luks.devices = {
        "luks-1f1eff14-7736-4c3f-be41-027a7a2bab3c".device =
          "/dev/disk/by-uuid/1f1eff14-7736-4c3f-be41-027a7a2bab3c";
        "luks-c781dcd3-48f1-4489-aa58-afe4d2ea3e8e".device =
          "/dev/disk/by-uuid/c781dcd3-48f1-4489-aa58-afe4d2ea3e8e";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/EFCA-BC36";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      swapDevices = [
        { device = "/dev/disk/by-uuid/b13fc3f8-2563-4a5a-9ad9-62d68b5212e5"; }
      ];

      # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
      # (the default) this is the recommended approach. When using systemd-networkd it's
      # still possible to use this option, but it's recommended to use it in conjunction
      # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
      # networking.useDHCP = lib.mkDefault true;

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      # --- System-level hardware configuration (power, graphics, audio, bluetooth) ---

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
      services.logind.settings.Login.PowerKey = "suspend-then-hibernate";
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
      fileSystems."/too" = {
        device = "/dev/disk/by-label/data_too";
        fsType = "btrfs";
        options = [
          "nofail"
          "x-systemd.mount-timeout=5s"
        ];
      };
    };
}
