# a simple script to automate the importing of the config
sudo mv /etc/nixos /etc/nixos.bak  # backup the original configuration
sudo cp /etc/nixos.bak/hardware-configuration.nix ~/nixos-config/ # move the auto-generated hardware scan file to this repo's directory
sudo chown ${USER}:users ~/nixos-config/hardware-configuration.nix # set ownership of the moved hw-cfg file
sudo ln -s ~/nixos-config /etc/nixos # create symlink to /etc/nixos so nixos knows where to look for the flake by default