{
  description = "My super awesome system flake";

  inputs = {
    # setting the root url for nixpkgs, using the unstable branch
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # hardware config repo for nixos
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # home manager flake
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # repo for nix-flatpak
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    # gaming utilities
    nix-gaming.url = "github:fufexan/nix-gaming";
    # repo for nix-iwd-provisioning
    nix-iwd-provisioning.url = "git+https://git.cl0vr.co/cl0vr/nix-iwd-provisioning/?ref=main";
    # secrets handling
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # secure boot management
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # --- home environment inputs ---
    # selfprivacy repo
    self-privacy = {
      url = "git+https://git.selfprivacy.org/SelfPrivacy/selfprivacy.org.app/?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # zen browser flake
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =

    {
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      nix-flatpak,
      nix-gaming,
      nix-iwd-provisioning,
      sops-nix,
      lanzaboote,
      self-privacy,
      zen-browser,
      ...
    }@inputs:
    {
      nixosConfigurations.TheUnreliable =
        let
          system = "x86_64-linux";
          # system = nixpkgs.stdenv.hostPlatform.system;
        in
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            inherit system;
          };
          modules = [
            # hardware config for the fw16
            nixos-hardware.nixosModules.framework-16-7040-amd
            ./config/system/framework.nix
            # sops cfg
            sops-nix.nixosModules.sops
            ./config/system/sops.nix
            # home manager config
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users."coucoucl0vr" = ./home.nix;
              home-manager.extraSpecialArgs =

                {
                  inherit system;
                  inherit inputs;
                };
            }
            # lanzaboote config
            lanzaboote.nixosModules.lanzaboote
            ./config/system/secure-boot.nix
            # pkgs config
            ./config/system/pkgs.nix
            # security config
            ./config/system/security.nix
            # networking conf
            ./config/system/networking.nix
            # eduroam/general iwd provisioning
            nix-iwd-provisioning.nixosModules.nix-iwd-provisioning
            ./config/system/iwd.nix
            # declarative flatpak management
            nix-flatpak.nixosModules.nix-flatpak
            ./config/system/flatpak.nix
            # ai config
            ./config/system/ai.nix
            # proxy config
            ./config/system/proxies.nix
            # plymouth config
            ./config/system/plymouth.nix
            # font config
            ./config/system/fonts.nix
            # wayland config
            ./config/system/wayland.nix
            # display manager config
            ./config/system/display-manager.nix
            # desktop interface config
            ./config/system/desktop.nix
            # tailscale config
            ./config/system/tailscale.nix
            # mullvad config
            ./config/system/mullvad.nix
            # gaming config
            nix-gaming.nixosModules.platformOptimizations
            ./config/system/gaming.nix
            # vr config
            ./config/system/vr.nix
            # graphics config
            ./config/system/graphics.nix
            # waydroid config
            ./config/system/waydroid.nix
            # android dev config
            ./config/system/android.nix
            # system optimisation config
            ./config/system/optimisations.nix
            # power management config
            ./config/system/power.nix
            # nh cli config
            ./config/system/nh.nix
            # shortcuts config
            ./config/system/shortcuts.nix
            # this is the old config method, importing it here so its settings are still applied
            ./configuration.nix
          ];
        };
    };
}
