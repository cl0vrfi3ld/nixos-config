{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.battery =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      systemd.user.services.auto-rr-throttle =
        let
          path =
            if config.features.niri.shell == "dms" then
              [
                pkgs.niri
              ]
            else
              [
                self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri
              ];
        in
        {
          inherit path;
          description = "Automatically throttle max refresh rate when on battery";
          after = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          wantedBy = [ "graphical-session.target" ];
          serviceConfig = {
            Restart = "on-failure";
            ExecStart = pkgs.writeShellScript "rr-manager" ''
              apply_rr() {
                if [ "$1" = "battery" ]; then
                    echo "Switched to Battery: Setting 60Hz"
                    niri msg output eDP-2 mode 2560x1600@60.002
                else
                    echo "Switched to AC: Setting 165Hz"
                    niri msg output eDP-2 mode 2560x1600@165.000
                fi
              }

              STATUS=$(cat /sys/class/power_supply/ACAD/online)
              if [ "$STATUS" = "0" ]; then apply_rr "battery"; else apply_rr "ac"; fi

              ${pkgs.upower}/bin/upower --monitor | while read -r line; do
                if [[ "$line" == *"line_power"* ]] || [[ "$line" == *"online:"* ]]; then
                   sleep 0.5
                   NEW_STATUS=$(cat /sys/class/power_supply/ACAD/online)
                   if [ "$NEW_STATUS" = "0" ]; then apply_rr "battery"; else apply_rr "ac"; fi
                fi
              done
            '';
          };
        };

      systemd.services.power-profile-switcher = {
        description = "Automatically switch power profile on battery/AC";
        after = [ "upower.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Restart = "on-failure";
          ExecStart = pkgs.writeShellScript "power-profile-switcher" ''
            apply_profile() {
              if [ "$1" = "battery" ]; then
                 echo "Switched to Battery: Setting balanced profile"
                 ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced
              else
                 echo "Switched to AC: Setting performance profile"
                 ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance
              fi
            }

            STATUS=$(cat /sys/class/power_supply/ACAD/online)
            if [ "$STATUS" = "0" ]; then apply_profile "battery"; else apply_profile "ac"; fi

            ${pkgs.upower}/bin/upower --monitor | while read -r line; do
              if [[ "$line" == *"line_power"* ]] || [[ "$line" == *"online:"* ]]; then
                 sleep 0.5
                 NEW_STATUS=$(cat /sys/class/power_supply/ACAD/online)
                 if [ "$NEW_STATUS" = "0" ]; then apply_profile "battery"; else apply_profile "ac"; fi
              fi
            done
          '';
        };
      };

    };
}
