{ config, pkgs, ... }:

{
  # Shell Aliases (Bash/Zsh/etc.)
  environment.shellAliases = {
    # System
    # rebuild = "sudo nixos-rebuild switch --flake .#default";
    # clean = "nix-collect-garbage -d";

    # Navigation
    # ".." = "cd ..";
    
    # Utilities
    # ll = "ls -lha";
    # grep = "grep --color=auto";
  };

  # Custom scripts for more complex shortcuts
  environment.systemPackages = [
    # (pkgs.writeShellScriptBin "hello-world" ''
    #   echo "Hello World"
    # '')
  ];
}
