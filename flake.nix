{
  description = "My super awesome system flake";

  inputs = {
    # setting the root url for nixpkgs, using the unstable branch
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/192a99b3c66089b8ef342971d5d47b0e8b72527c";
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
      url = "git+https://git.outfoxxed.me/quickshell/quickshell/?ref=refs/tags/v0.3.0";
      # url = "github:quickshell-mirror/quickshell"; # github mirror
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # source builds of dms
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        quickshell.follows = "quickshell";
      };
    };
    # DankMaterialShell plugin registry
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # gaming utilities
    nix-gaming.url = "github:fufexan/nix-gaming";
    # star citizen!
    nix-citizen = {
      url = "github:LovingMelody/nix-citizen";
      inputs.nix-gaming.follows = "nix-gaming";
    };
    # repo for nix-iwd-provisioning
    nix-iwd-provisioning.url = "git+https://git.cl0vr.co/cl0vr/nix-iwd-provisioning/?ref=main";
    # secrets handling
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # secure boot management
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- home environment inputs ---
    # pano scrobbler
    pano-scrobbler = {
      url = "github:kawaiiDango/pano-scrobbler-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # selfprivacy repo
    self-privacy.url = "git+https://git.selfprivacy.org/SelfPrivacy/selfprivacy.org.app/?ref=master";
    # zen browser flake
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
    sysc-greet = {
      url = "github:Nomadcxx/sysc-greet";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];
      imports = [
        (inputs.import-tree ./modules)
      ];
    };
}
