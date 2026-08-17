{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.virtualisation =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      config = {
        # Virtualisation (Podman)
        virtualisation = {
          containers.enable = true;
          podman = {
            enable = true;
            dockerCompat = true;
            defaultNetwork.settings.dns_enabled = true;
          };
        };

        environment.systemPackages = [ pkgs.slirp4netns ];
        environment.etc."containers/registries.conf".text = lib.mkDefault ''
          [registries.search]
          registries = ['docker.io']
        '';

        # Home-Manager configuration per user
        home-manager.users = self.lib.applyDesktopHome config (username: {
          # Podman containers registry config
          xdg.configFile."containers/registries.conf".text = ''
            [registries.search]
            registries = ['docker.io']
          '';
        });
      };
    };
}
