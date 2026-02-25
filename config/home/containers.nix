{ config, pkgs, ... }:

{
  # User-scoped `~/.config/containers/registries`
  xdg.configFile."containers/registries.conf".text = ''
    [registries.search]
    registries = ['docker.io']
  '';
}
