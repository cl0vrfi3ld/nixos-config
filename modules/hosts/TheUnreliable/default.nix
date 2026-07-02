{ self, inputs, ... }: {
  flake.nixosConfigurations.TheUnreliable =
    let
      system = "x86_64-linux";
    in
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs system;
      };
      modules = [
        # Host-specific modules
        self.nixosModules.TheUnreliable-hardware
        self.nixosModules.TheUnreliable-configuration

        # Dendritic Feature Modules
        self.nixosModules.core
        self.nixosModules.nh
        self.nixosModules.users
        self.nixosModules.niri
        self.nixosModules.desktop-suite
        # --- noctalia setup ---
        # self.nixosModules.tuigreet
        self.nixosModules.ly
        self.nixosModules.noctalia
        # --- dms setup ---
        # self.nixosModules.dms

        # Hardware inputs for fw16
        inputs.nixos-hardware.nixosModules.framework-16-7040-amd

        # sops cfg
        inputs.sops-nix.nixosModules.sops

        # home manager config (base)
        inputs.home-manager.nixosModules.home-manager
        {
          # Keep old home.nix until fully migrated
          home-manager.users."coucoucl0vr" = ../../../home.nix;
          home-manager.extraSpecialArgs = {
            inherit system inputs;
          };
        }

        # lanzaboote config (not migrated yet)
        inputs.lanzaboote.nixosModules.lanzaboote

        # eduroam/general iwd provisioning (not migrated yet)
        inputs.nix-iwd-provisioning.nixosModules.nix-iwd-provisioning

        # declarative flatpak management (not migrated yet)
        inputs.nix-flatpak.nixosModules.nix-flatpak

        # sysc-greet stuff
        inputs.sysc-greet.nixosModules.default

        # DankMaterialShell config (not migrated yet)
        inputs.dms.nixosModules.dank-material-shell
        inputs.dms.nixosModules.greeter
        inputs.dms-plugin-registry.modules.default

        # gaming config (not migrated yet)
        inputs.nix-gaming.nixosModules.platformOptimizations

        # nix-citizen stuff (not migrated yet)
        inputs.nix-citizen.nixosModules.default

        # --- System Config Modules (Legacy, not migrated yet) ---
        ../../../config/system/overrides.nix
        ../../../config/system/boot.nix
        # removed ../../../config/system/core.nix (handled by features.core)
        ../../../config/system/hardware.nix
        ../../../config/system/network.nix
        ../../../config/system/apps.nix
        ../../../config/system/gaming.nix
        ../../../config/system/security.nix
        ../../../config/system/secrets.nix
      ];
    };
}
