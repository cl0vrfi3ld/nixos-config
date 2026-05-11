{
  description = "My super awesome system flake";

  inputs = {
    # setting the root url for nixpkgs, using the unstable branch
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-systemd-compat.url = "github:NixOS/nixpkgs/192a99b3c66089b8ef342971d5d47b0e8b72527c";
    # hardware config repo for nixos
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # home manager flake
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # repo for nix-flatpak
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    # source builds of quickshell
    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
      # url = "github:quickshell-mirror/quickshell"; # github mirror
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # source builds of dms
    # dms = {
    #   url = "github:AvengeMedia/DankMaterialShell/stable";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # DankMaterialShell plugin registry
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
            # sops cfg
            sops-nix.nixosModules.sops
            # home manager config
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users."coucoucl0vr" = ./home.nix;
              home-manager.extraSpecialArgs = {
                inherit system;
                inherit inputs;
              };

              # when overwriting files, back 'em up!
              home-manager.backupFileExtension = "old";
            }
            # lanzaboote config
            lanzaboote.nixosModules.lanzaboote
            # eduroam/general iwd provisioning
            nix-iwd-provisioning.nixosModules.nix-iwd-provisioning
            # declarative flatpak management
            nix-flatpak.nixosModules.nix-flatpak
            # gaming config
            nix-gaming.nixosModules.platformOptimizations

            # --- System Config Modules ---
            ./config/system/overrides.nix
            ./config/system/boot.nix
            ./config/system/core.nix
            ./config/system/hardware.nix
            ./config/system/network.nix
            ./config/system/desktop.nix
            ./config/system/apps.nix
            ./config/system/gaming.nix
            ./config/system/security.nix
            ./config/system/secrets.nix

            # this is the old config method, importing it here so its settings are still applied
            ./configuration.nix
          ];
        };
    };
}
