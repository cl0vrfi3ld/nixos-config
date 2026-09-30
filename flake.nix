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
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=latest";
    };
    # source builds of quickshell
    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell/?ref=refs/tags/v0.3.1";
      # url = "github:quickshell-mirror/quickshell"; # github mirror
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # source builds of dms
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    # DankMaterialShell plugin registry
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # gaming utilities
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # star citizen!
    nix-citizen = {
      url = "github:LovingMelody/nix-citizen";
      inputs.nix-gaming.follows = "nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # repo for nix-iwd-provisioning
    nix-iwd-provisioning = {
      url = "git+https://git.cl0vr.co/cl0vr/nix-iwd-provisioning/?ref=main";
    };
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
    self-privacy = {
      url = "git+https://git.selfprivacy.org/SelfPrivacy/selfprivacy.org.app/?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # zen browser flake
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # hermes agent
    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
    };
    # llm agent packages
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # cua computer-use driver
    cua = {
      url = "github:trycua/cua";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    memory-buckets = {
      url = "git+https://git.cl0vr.co/cl0vr/memory-buckets";
      # or the GitHub mirror: url = "github:cl0vrfi3ld/memory-buckets";
      flake = false;  # only nix/package.nix is used
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

      # Groups of flake inputs, updated together via `flake-update --group <name>`
      flake.meta.inputGroups = {
        core = [
          "nixpkgs"
          "home-manager"
          "nixos-hardware"
        ];
        flake = [
          "flake-parts"
          "import-tree"
          "wrapper-modules"
        ];
        system = [
          "sops-nix"
          "lanzaboote"
          "nix-iwd-provisioning"
          "nix-flatpak"
        ];
        gaming = [
          "nix-gaming"
          "nix-citizen"
        ];
        apps = [
          "zen-browser"
          "pano-scrobbler"
          "self-privacy"
        ];
        ai = [
          "hermes-agent"
          "llm-agents"
          "cua"
        ];
        # inactive: DMS is deprecated, sysc-greet is unused
        legacy = [
          "dms"
          "dms-plugin-registry"
          "quickshell"
          "sysc-greet"
        ];
      };
    };
}
