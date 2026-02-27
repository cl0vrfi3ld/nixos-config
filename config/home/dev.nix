{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    kdePackages.kate
    nixd
    nixfmt
    nodejs
    bun
    forgejo-cli
    shellcheck
    shfmt
    antigravity-fhs
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "cl0vrfi3ld";
      user.email = "cl0vr@noreply.git.cl0vr.co";
      init.defaultBranch = "main";
    };
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium-fhs;
  };

  # User-level ssh config
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "clovergit" = {
        hostname = "git.cl0vr.co";
        user = "gitea";
        identityFile = "~/.ssh/id_gitea_cl0vrco.pub";
        identitiesOnly = true;
      };
      "LaptopBackupBox" = {
        hostname = "apollo.borg.cl0vr.co";
        user = "u455601-sub1";
        port = 23;
        identityFile = "~/.ssh/id_ed25519-backupbox.pub";
        identitiesOnly = true;
      };
      "MovieMediaBox" = {
        hostname = "u455601-sub5.your-storagebox.de";
        user = "u455601-sub5";
        port = 23;
      };
      "root.cl0vr.co" = {
        hostname = "cl0vr.co";
        user = "root";
        identityFile = "~/.ssh/id_root_cl0vrco.pub";
        identitiesOnly = true;
      };
      "selfprivacy" = {
        hostname = "git.selfprivacy.org";
        user = "gitea";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };
    };
    enableDefaultConfig = false;
    matchBlocks."*" = {
      forwardAgent = false;
      addKeysToAgent = "no";
      compression = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      userKnownHostsFile = "~/.ssh/known_hosts";
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
    };
  };

  home.file = {
    ".ssh/config".force = true;
  };
  home.activation = {
    fixSshPermissions = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run install -d -m 0700 "$HOME/.ssh"
      if [ -L "$HOME/.ssh/config" ]; then
        src="$(readlink -f "$HOME/.ssh/config")"
        run rm -f "$HOME/.ssh/config"
        run install -m 0600 "$src" "$HOME/.ssh/config"
      fi
    '';
  };

  # Podman containers registry config
  xdg.configFile."containers/registries.conf".text = ''
    [registries.search]
    registries = ['docker.io']
  '';
}
