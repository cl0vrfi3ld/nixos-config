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
        self.nixosModules.battery
        # system
        self.nixosModules.boot
        self.nixosModules.networking
        self.nixosModules.security
        self.nixosModules.pam
        self.nixosModules.sops
        self.nixosModules.virtualisation
        self.nixosModules.flatpak
        self.nixosModules.fish
        self.nixosModules.gaming
        self.nixosModules.bitwarden
        self.nixosModules.compat
        self.nixosModules.gpu
        # home
        self.nixosModules.dev
        self.nixosModules.ssh
        self.nixosModules.browser
        self.nixosModules.user-apps
        self.nixosModules.ai
        self.nixosModules.xdg-mime
        # --- noctalia setup ---
        # self.nixosModules.tuigreet
        self.nixosModules.ly
        self.nixosModules.noctalia
        # --- dms setup ---
        # self.nixosModules.dms

        # home manager config (base)
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = {
            inherit system inputs;
          };
        }
      ];
    };
}
