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
    let
      # `upower --monitor` emits several matching lines per plug event, which used
      # to re-fire each handler ~5x per transition. Track the last applied state
      # and skip no-op transitions.
      #
      # The monitor is read via process substitution rather than a pipeline so the
      # loop stays in the parent shell and $last actually persists across events.
      mkPowerWatcher =
        {
          name,
          onBattery,
          onAC,
        }:
        pkgs.writeShellScript name ''
          get_ac_status() {
            for f in /sys/class/power_supply/ACAD/online \
                     /sys/class/power_supply/AC/online \
                     /sys/class/power_supply/ADP*/online \
                     /sys/class/power_supply/AC*/online; do
              if [ -r "$f" ]; then
                cat "$f"
                return
              fi
            done
            echo 1
          }

          last=""
          apply() {
            [ "$1" = "$last" ] && return 0
            last="$1"
            if [ "$1" = "0" ]; then
              ${onBattery}
            else
              ${onAC}
            fi
          }

          apply "$(get_ac_status)"

          while read -r line; do
            case "$line" in
              *line_power* | *online:* | *state:*)
                sleep 0.5
                apply "$(get_ac_status)"
                ;;
            esac
          done < <(${lib.getExe' pkgs.upower "upower"} --monitor)
        '';
      batteryWatts = pkgs.writeShellScriptBin "battery-watts" ''
        bat="$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1)"
        [ -z "$bat" ] && { echo "No battery found" >&2; exit 1; }
        while true; do
          i="$(cat "$bat/current_now" 2>/dev/null || echo 0)"
          v="$(cat "$bat/voltage_now" 2>/dev/null || echo 0)"
          status="$(cat "$bat/status" 2>/dev/null)"
          watts=$(${lib.getExe pkgs.gawk} -v i="$i" -v v="$v" 'BEGIN { printf "%.2f", (i * v) / 1000000000000 }')
          echo "$(date +%H:%M:%S) $status: $watts W"
          sleep 2
        done
      '';

      gpuWakeLogger = pkgs.writeShellScriptBin "gpu-wake-logger" ''
        dev="/sys/class/drm/card1/device/power"
        [ -r "$dev/runtime_active_time" ] || { echo "dGPU power node not found" >&2; exit 1; }
        last="$(cat "$dev/runtime_active_time")"
        laststatus="$(cat "$dev/runtime_status")"
        echo "$(date +%H:%M:%S) baseline: status=$laststatus active_ms=$last"
        while true; do
          sleep 2
          now="$(cat "$dev/runtime_active_time")"
          status="$(cat "$dev/runtime_status")"
          if [ "$now" != "$last" ] || [ "$status" != "$laststatus" ]; then
            echo "$(date +%H:%M:%S) status=$status active_ms=$now (delta=$((now - last)))"
            last="$now"
            laststatus="$status"
          fi
        done
      '';
    in
    {
      environment.systemPackages = [
        pkgs.powertop
        pkgs.iw
        batteryWatts
        gpuWakeLogger
      ];

      # Lid-close suspend/hibernate is owned solely by logind
      # (services.logind.settings.Login.HandleLidSwitch in hardware.nix); this only
      # locks the screen before sleep so the two don't race (see niri.nix).
      systemd.user.services.lock-before-sleep = lib.mkIf (config.features.niri.shell == "noctalia") {
        description = "Lock screen before suspend/hibernate";
        before = [ "sleep.target" ];
        wantedBy = [ "sleep.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.myNoctalia} ipc call lockScreen lock";
        };
      };

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
            # `on-failure` would not restart this: if upower dies the loop hits
            # EOF and the script exits 0, silently stopping refresh switching.
            Restart = "always";
            RestartSec = "2s";
            ExecStart = mkPowerWatcher {
              name = "rr-manager";
              onBattery = ''
                echo "Switched to Battery: Setting 60Hz"
                niri msg output eDP-2 mode 2560x1600@60.002 || true
              '';
              onAC = ''
                echo "Switched to AC: Setting 165Hz"
                niri msg output eDP-2 mode 2560x1600@165.000 || true
              '';
            };
          };
        };

      systemd.services.power-profile-switcher = {
        description = "Automatically switch power profile on battery/AC";
        # Deliberately not ordered after power-profiles-daemon.service: doing so
        # creates a shutdown ordering cycle through multi-user.target (both units
        # are WantedBy it). powerprofilesctl talks to power-profiles-daemon over
        # D-Bus, which activates it on demand, so no explicit ordering is needed.
        after = [ "upower.service" ];
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.coreutils ];
        serviceConfig = {
          # See the note on auto-rr-throttle above.
          Restart = "always";
          RestartSec = "2s";
          ExecStart = mkPowerWatcher {
            name = "power-profile-switcher";
            onBattery = ''
              echo "Switched to Battery: Setting power-saver profile"
              ${lib.getExe' pkgs.power-profiles-daemon "powerprofilesctl"} set power-saver || true
            '';
            onAC = ''
              echo "Switched to AC: Setting performance profile"
              ${lib.getExe' pkgs.power-profiles-daemon "powerprofilesctl"} set performance || true
            '';
          };
        };
      };

    };
}
