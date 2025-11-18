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
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      nix-flatpak,
      nix-iwd-provisioning,
      sops-nix,
      ...
    }@inputs:
    {
      nixosConfigurations.theseus = nixpkgs.lib.nixosSystem {
        modules = [
          # hardware config for the fw16
          nixos-hardware.nixosModules.framework-16-7040-amd
          # sops cfg
          sops-nix.nixosModules.sops
          ./config/sops.nix
          # pkgs config
          ./config/pkgs.nix
          # eduroam/general iwd provisioning
          nix-iwd-provisioning.nixosModules.nix-iwd-provisioning
          ./config/iwd.nix
          # declarative flatpak management
          nix-flatpak.nixosModules.nix-flatpak
          ./config/flatpak.nix
          # ollama config
          # ./config/ollama.nix
          # plymouth config
          ./config/plymouth.nix
          # font config
          ./config/fonts.nix
          # nix package manager config
          ./config/nix-config.nix
          # this is the old config method, importing it here so its settings are still applied
          ./configuration.nix
        ];
      };
    };
}
