{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.ssh =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      config = {
        home-manager.users = self.lib.applyDesktopHome config (
          username:
          { lib, ... }:
          {
            # User-level ssh config
            programs.ssh = {
              enable = true;
              enableDefaultConfig = false;
              settings = {
                "clovergit" = {
                  HostName = "git.cl0vr.co";
                  User = "gitea";
                  IdentityFile = "~/.ssh/id_gitea_cl0vrco.pub";
                  IdentitiesOnly = "yes";
                };
                "LaptopBackupBox" = {
                  HostName = "apollo.borg.cl0vr.co";
                  User = "u455601-sub1";
                  Port = 23;
                  IdentityFile = "~/.ssh/id_ed25519-backupbox.pub";
                  IdentitiesOnly = "yes";
                };
                "MovieMediaBox" = {
                  HostName = "u455601-sub5.your-storagebox.de";
                  User = "u455601-sub5";
                  Port = 23;
                };
                "root.cl0vr.co" = {
                  HostName = "cl0vr.co";
                  User = "root";
                  IdentityFile = "~/.ssh/id_root_cl0vrco.pub";
                  IdentitiesOnly = "yes";
                };
                "selfprivacy" = {
                  HostName = "git.selfprivacy.org";
                  User = "gitea";
                  IdentityFile = "~/.ssh/id_ed25519";
                  IdentitiesOnly = "yes";
                };
                "*" = {
                  ForwardAgent = "no";
                  AddKeysToAgent = "no";
                  Compression = "no";
                  ServerAliveInterval = 0;
                  ServerAliveCountMax = 3;
                  HashKnownHosts = "no";
                  UserKnownHostsFile = "~/.ssh/known_hosts";
                  ControlMaster = "no";
                  ControlPath = "~/.ssh/master-%r@%n:%p";
                  ControlPersist = "no";
                };
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
          }
        );
      };
    };
}
