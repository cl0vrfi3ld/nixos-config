{ self, inputs, lib, ... }: {
  flake.nixosModules.users = { config, pkgs, lib, ... }: {
    options.features.users = {
      users = lib.mkOption {
        description = "Attribute set of users to configure on the system.";
        default = {};
        type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = "The username of the user.";
            };
            description = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "Full name / description of the user.";
            };
            extraGroups = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
              description = "Extra groups for the user.";
            };
            shell = lib.mkOption {
              type = lib.types.package;
              default = pkgs.fish;
              description = "The shell package to use for this user.";
            };
            isNormalUser = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether this is a normal user.";
            };
            isDesktopUser = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether this is a desktop user (enables desktop configs, theming).";
            };
            createHome = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether to create the home directory.";
            };
            openssh.authorizedKeys.keys = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
              description = "SSH authorized keys for the user.";
            };
            sessionVariables = lib.mkOption {
              type = lib.types.attrsOf lib.types.str;
              default = {};
              description = "Session variables to set via Home Manager.";
            };
          };
        }));
      };
    };

    config = {
      users.users = lib.mapAttrs (username: userConfig: {
        isNormalUser = userConfig.isNormalUser;
        description = userConfig.description;
        extraGroups = userConfig.extraGroups;
        shell = userConfig.shell;
        createHome = userConfig.createHome;
        openssh.authorizedKeys.keys = userConfig.openssh.authorizedKeys.keys;
      }) config.features.users.users;

      home-manager.users = lib.mapAttrs (username: userConfig: {
        home.sessionVariables = userConfig.sessionVariables;
      }) config.features.users.users;
    };
  };
}
