{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.lib = {
    # Get the list of usernames of desktop users
    getDesktopUsers =
      config:
      lib.attrNames (lib.filterAttrs (name: user: user.isDesktopUser) config.features.users.users);

    # Apply home-manager config to all desktop users
    # USAGE
    # ```nix
    # home-manager.users = self.lib.applyDesktopHome config (username: {
    #  home.packages = with pkgs; [
    #    firefox
    #  ];
    # });
    # ```
    applyDesktopHome =
      config: homeAttrs:
      lib.genAttrs (self.lib.getDesktopUsers config) (
        username: if builtins.isFunction homeAttrs then homeAttrs username else homeAttrs
      );

  };
}
