{ config, ... }:

{ 
  # automatically collect garbage each week
  nix.gc = {
    automatic = true;
    dates = "Tue,Thu 10:00..17:00"; # Or a specific time like "03:15"
    options = "-d"; # Optional: Delete old generations
  };

}
