{
	description = "My super awesome system flake";

	inputs = {
		# setting the root url for nixpkgs, using the unstable branch
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		# hardware config repo for nixos
		nixos-hardware.url = "github:NixOS/nixos-hardware/master";
		# repo for nix-flatpak
		nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
	};

	outputs = { self, nixpkgs, nixos-hardware, nix-flatpak, ... }@inputs: {
		nixosConfigurations.theseus = nixpkgs.lib.nixosSystem {
			modules = [
				# hardware config for the fw16
				nixos-hardware.nixosModules.framework-16-7040-amd
				# declarative flatpak management
				nix-flatpak.nixosModules.nix-flatpak
				./config/flatpak.nix
				# plymouth config
				./config/plymouth.nix
				# this is the old config method, importing it here so its settings are still applied
				./configuration.nix
			];
		};
	};
}
