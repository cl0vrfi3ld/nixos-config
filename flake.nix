{
  description = "My super awesome system flake";

  inputs = {
    # setting the root url for nixpkgs, using the unstable branch
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # hardware config repo for nixos
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # repo for nix-flatpak
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    # repo for nix-iwd-provisioning
    nix-iwd-provisioning.url = "git+https://git.cl0vr.co/cl0vr/nix-iwd-provisioning/?ref=main";
    # secrets handling
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    # secure boot management
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      nix-flatpak,
      nix-iwd-provisioning,
      sops-nix,
      lanzaboote,
      ...
    }@inputs:
    {
      nixosConfigurations.TheUnreliable = nixpkgs.lib.nixosSystem {
        modules = [
          # hardware config for the fw16
          nixos-hardware.nixosModules.framework-16-7040-amd
          # sops cfg
          sops-nix.nixosModules.sops
          ./config/sops.nix
          # lanzaboote config
          lanzaboote.nixosModules.lanzaboote
          ./config/secure-boot.nix
          # pkgs config
          ./config/pkgs.nix
          # networking conf
          ./config/networking.nix
          # eduroam/general iwd provisioning
          nix-iwd-provisioning.nixosModules.nix-iwd-provisioning
          ./config/iwd.nix
          # declarative flatpak management
          nix-flatpak.nixosModules.nix-flatpak
          ./config/flatpak.nix
          # ai config
          ./config/ai.nix
          # proxy config
          ./config/proxies.nix
          # plymouth config
          ./config/plymouth.nix
          # font config
          ./config/fonts.nix
          # wayland config
          ./config/wayland.nix
          # display manager config
          ./config/display-manager.nix
          # desktop manager config
          ./config/desktop-manager.nix
          # tailscale config
          ./config/tailscale.nix
          # mullvad config
          ./config/mullvad.nix
          # gaming config
          ./config/gaming.nix
          # vr config
          ./config/vr.nix
          # graphics config
          ./config/graphics.nix
          # waydroid config
          ./config/waydroid.nix
          # android dev config
          ./config/android.nix
          # system optimisation config
          ./config/optimisations.nix

          # nh cli config
          ./config/nh.nix
          # shortcuts config
          ./config/shortcuts.nix
          # this is the old config method, importing it here so its settings are still applied
          ./configuration.nix
        ];
      };
    };
}

