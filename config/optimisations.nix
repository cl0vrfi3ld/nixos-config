# various system optimisations
{ config, pkgs,  ... }:
{ 
  # automatically collect garbage each week
  nix.gc = {
    automatic = true;
    dates = "weekly"; # Or a specific time like "03:15"
    options = "-d"; # Optional: Delete old generations
  };
  nix.settings = {
    sandbox = true;
    # sandbox-paths = [ "/bin/sh=${pkgs.busybox-sandbox-shell.out}/bin/busybox" ];
    
    show-trace = true;
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
    max-jobs = "auto"; # Allow Nix to build multiple packages in parallel
    builders-use-substitutes = true; # Use binary caches during builds
    };

  # Filesystem optimisations for SSDs
  services.fstrim.enable = true;

  # Power management optimisations
  services.power-profiles-daemon.enable = true;

  # Use a RAM disk for /tmp to reduce wear on the SSD and improve speed
  boot.tmp.useTmpfs = true;
}

