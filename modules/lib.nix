{ self, inputs, lib, ... }: {
  flake.lib = {
    # Get the list of usernames of desktop users
    getDesktopUsers = config:
      lib.mapAttrsToList (name: user: name) (
        lib.filterAttrs (name: user: user.isDesktopUser) config.features.users.users
      );

    # Apply home-manager config to all desktop users
    mkDesktopHome = config: homeAttrs: {
      home-manager.users = lib.genAttrs (self.lib.getDesktopUsers config) (username:
        if builtins.isFunction homeAttrs then homeAttrs username else homeAttrs
      );
    };
  };
}
