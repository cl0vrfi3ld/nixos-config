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
    # use-sandbox = true;
    # sandbox-paths = [ "/bin/sh=${pkgs.busybox-sandbox-shell.out}/bin/busybox" ];
    
    show-trace = true;
    auto-optimise-store = true;
  }
  ;
}
