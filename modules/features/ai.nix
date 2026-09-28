{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.ai =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.features.ai;
    in
    {
      options.features.ai = {
        hermes-agent = {
          enable = lib.mkEnableOption "the Hermes Agent CLI (programs.hermes-agent)";
          desktop.enable = lib.mkEnableOption "the Hermes Agent desktop application";
        };
      };

      config = {
        home-manager.sharedModules = [ inputs.hermes-agent.homeManagerModules.default ];

        home-manager.users = self.lib.applyDesktopHome config (username: {
          # Hermes Agent
          services.hermes-agent = {
            enable = true;
            backend.mode = "serve";
            backend.port = 9119;
            environmentFiles = [ config.sops.secrets."hermes-agent".path ];
          };
          programs.hermes-agent = {
            enable = cfg.hermes-agent.enable;
            desktop.enable = cfg.hermes-agent.desktop.enable;
          };
        });
      };
    };
}
