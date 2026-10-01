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
      options.features.ssh = {
        hosts = lib.mkOption {
          description = "SSH host configurations keyed by alias.";
          default = { };
          type = lib.types.attrsOf (
            lib.types.submodule (
              { name, ... }:
              {
                options = {
                  hostName = lib.mkOption {
                    type = lib.types.str;
                    description = "The remote hostname or IP.";
                  };
                  user = lib.mkOption {
                    type = lib.types.str;
                    default = "git";
                    description = "The remote user.";
                  };
                  port = lib.mkOption {
                    type = lib.types.nullOr lib.types.port;
                    default = null;
                    description = "The remote SSH port.";
                  };
                  identityFile = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = null;
                    description = "Path to the private key (or public key, if that's what you have).";
                  };
                  identitiesOnly = lib.mkOption {
                    type = lib.types.bool;
                    default = true;
                    description = "Whether to force the use of the specified identity file.";
                  };
                  extraConfig = lib.mkOption {
                    type = lib.types.attrsOf lib.types.str;
                    default = { };
                    description = "Extra SSH config key-value pairs.";
                  };
                };
              }
            )
          );
        };
      };

      config = {
        home-manager.users = self.lib.applyDesktopHome config (
          username:
          { lib, ... }:
          let
            sshHostToConfig =
              name: host:
              {
                HostName = host.hostName;
                User = host.user;
                IdentitiesOnly = if host.identitiesOnly then "yes" else "no";
              }
              // lib.optionalAttrs (host.identityFile != null) { IdentityFile = host.identityFile; }
              // lib.optionalAttrs (host.port != null) { Port = toString host.port; }
              // host.extraConfig;
          in
          {
            # User-level ssh config
            programs.ssh = {
              enable = true;
              enableDefaultConfig = false;
              settings = lib.mapAttrs sshHostToConfig config.features.ssh.hosts // {
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
