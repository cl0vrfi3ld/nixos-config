# various system optimisations
{ config, pkgs,  ... }:
{ 
  # automatically collect garbage each week
  # nix.gc = {
  #   automatic = true;
  #   dates = "weekly"; # Or a specific time like "03:15"
  #   options = "--delete-older-than 7d"; # Optional: delete 7 days old generations
  # };
  
  # Enable ZRAM swap (compressed RAM)
  zramSwap.enable = true;
  zramSwap.memoryPercent = 50;

  # various nix settings
  nix.settings = {
    sandbox = true;
    show-trace = true;
    auto-optimise-store = true;
    max-jobs = "auto"; # allow Nix to build multiple packages in parallel
    builders-use-substitutes = true; # use binary caches during builds
    };

  # filesystem optimisations for SSDs
  services.fstrim.enable = true;
  
  # use a RAM disk for /tmp to reduce wear on the SSD and improve speed
  boot.tmp.useTmpfs = true;
  # boot.tmp.tmpfsSize = "75%";
}

