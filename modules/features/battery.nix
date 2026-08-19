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
          niriPkg =
            if config.features.niri.shell == "dms" then
              pkgs.niri
            else
              self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
        in
        {
          path = [
            pkgs.coreutils
            niriPkg
          ];
          description = "Automatically throttle max refresh rate when on battery";
          after = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          wantedBy = [ "graphical-session.target" ];
          serviceConfig = {
            Restart = "on-failure";
            RestartSec = "2s";
            ExecStart = pkgs.writeShellScript "rr-manager" ''
              get_ac_status() {
                for f in /sys/class/power_supply/ACAD/online /sys/class/power_supply/AC/online /sys/class/power_supply/ADP*/online /sys/class/power_supply/AC*/online; do
                  if [ -r "$f" ]; then
                    cat "$f"
                    return
                  fi
                done
                echo "1"
              }

              apply_rr() {
                if [ "$1" = "battery" ]; then
                    echo "Switched to Battery: Setting 60Hz"
                    niri msg output eDP-2 mode 2560x1600@60.002 || true
                else
                    echo "Switched to AC: Setting 165Hz"
                    niri msg output eDP-2 mode 2560x1600@165.000 || true
                fi
              }

              STATUS=$(get_ac_status)
              if [ "$STATUS" = "0" ]; then apply_rr "battery"; else apply_rr "ac"; fi

              ${pkgs.upower}/bin/upower --monitor | while read -r line; do
                if [[ "$line" == *"line_power"* ]] || [[ "$line" == *"online:"* ]] || [[ "$line" == *"state:"* ]]; then
                   sleep 0.5
                   NEW_STATUS=$(get_ac_status)
                   if [ "$NEW_STATUS" = "0" ]; then apply_rr "battery"; else apply_rr "ac"; fi
                fi
              done
            '';
          };
        };

      systemd.services.power-profile-switcher = {
        description = "Automatically switch power profile on battery/AC";
        after = [
          "upower.service"
          "power-profiles-daemon.service"
        ];
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.coreutils ];
        serviceConfig = {
          Restart = "on-failure";
          RestartSec = "2s";
          ExecStart = pkgs.writeShellScript "power-profile-switcher" ''
            get_ac_status() {
              for f in /sys/class/power_supply/ACAD/online /sys/class/power_supply/AC/online /sys/class/power_supply/ADP*/online /sys/class/power_supply/AC*/online; do
                if [ -r "$f" ]; then
                  cat "$f"
                  return
                fi
              done
              echo "1"
            }

            apply_profile() {
              if [ "$1" = "battery" ]; then
                 echo "Switched to Battery: Setting balanced profile"
                 ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced || true
              else
                 echo "Switched to AC: Setting performance profile"
                 ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance || true
              fi
            }

            STATUS=$(get_ac_status)
            if [ "$STATUS" = "0" ]; then apply_profile "battery"; else apply_profile "ac"; fi

            ${pkgs.upower}/bin/upower --monitor | while read -r line; do
              if [[ "$line" == *"line_power"* ]] || [[ "$line" == *"online:"* ]] || [[ "$line" == *"state:"* ]]; then
                 sleep 0.5
                 NEW_STATUS=$(get_ac_status)
                 if [ "$NEW_STATUS" = "0" ]; then apply_profile "battery"; else apply_profile "ac"; fi
              fi
            done
          '';
        };
      };

    };
}
