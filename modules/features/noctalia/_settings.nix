# Noctalia v5 settings, rendered to TOML by the nix-wrapper-modules `noctalia`
# wrapper (see ./default.nix). Ported by hand from the v4 (noctalia-shell)
# settings.json: v5 does not migrate v4 config.
#
# The underscore prefix keeps import-tree from loading this as a flake module.
#
# The rendered file is the read-only base layer. Changes made in the Settings
# GUI land in ~/.local/state/noctalia/settings.toml, which wins over this file;
# delete keys there if a value here seems to be ignored. Check this file with
# `noctalia config validate "$(nix build .#myNoctalia --print-out-paths)/noctalia/settings.toml"`.
{
  shell = {
    font_family = "DejaVu Sans";
    avatar_path = "~/.face";
    telemetry_enabled = false;

    shadow.direction = "down_right";

    launcher.pinned = [
      "zen-twilight"
      "dev.zed.Zed"
      "SONE"
      "org.kde.dolphin"
      "com.mitchellh.ghostty"
      "vesktop"
      "anytype"
      "hermes"
      "com.nousresearch.hermes"
    ];

    # v4 power menu: every entry behind a 10 s countdown, keys 1 to 7.
    # v5 has no built-in hibernate action, so it is a plain command row.
    session.actions =
      map
        (
          a:
          {
            countdown_seconds = 10;
          }
          // a
        )
        [
          {
            action = "lock";
            shortcut = "1";
          }
          {
            action = "suspend";
            shortcut = "2";
          }
          {
            action = "command";
            label = "Hibernate";
            glyph = "hibernate";
            command = "systemctl hibernate";
            shortcut = "3";
          }
          {
            action = "reboot";
            shortcut = "4";
          }
          {
            action = "logout";
            shortcut = "5";
          }
          {
            action = "shutdown";
            shortcut = "6";
          }
          {
            action = "reboot_uefi";
            shortcut = "7";
          }
        ];
  };

  theme = {
    mode = "dark";
    source = "wallpaper";
    wallpaper_scheme = "faithful";
    templates = {
      builtin_ids = [
        "niri" # writes ~/.config/niri/noctalia.kdl, optionally included by niri.nix
        "qt"
        "gtk3"
        "gtk4"
        "btop"
        "ghostty"
        "kcolorscheme"
      ];
      community_ids = [
        "zed"
        "zen-browser"
        "yazi"
        "discord"
        "steam"
        "vscode"
      ];
    };
  };

  wallpaper = {
    enabled = true;
    directory = "~/Wallpapers/Desktop";
    fill_mode = "crop";
    fill_color = "#000000";
    transition = [
      "fade"
      "disc"
      "stripes"
      "wipe"
      "pixel"
      "honeycomb"
    ];
    transition_duration = 1500;
    edge_smoothness = 5.0e-2;
    automation = {
      enabled = true;
      interval_seconds = 13200;
      order = "random";
    };
  };

  # Blurred wallpaper in niri's overview; pairs with the noctalia-backdrop
  # layer-rule in niri.nix.
  backdrop = {
    enabled = true;
    blur_intensity = 0.4;
    tint_intensity = 0.6;
  };

  lockscreen = {
    # Lock-before-sleep (logind PrepareForSleep, including lid close) is on by
    # default in v5; this replaces the old lock-before-sleep user unit.
    lock_before_suspend = true;
    blur_intensity = 0.0;
    tint_intensity = 0.0;
    transition = [ ];
  };

  idle = {
    pre_action_fade_seconds = 5.0;
    behavior_order = [
      "screen-off"
      "lock"
      "suspend"
    ];
    behavior = {
      screen-off = {
        timeout = 600;
        action = "screen_off";
        enabled = true;
      };
      lock = {
        timeout = 660;
        action = "lock";
        enabled = true;
      };
      suspend = {
        timeout = 1800;
        action = "suspend";
        enabled = true;
      };
    };
  };

  nightlight = {
    enabled = true;
    temperature_day = 6500;
    temperature_night = 3330;
  };

  location.auto_locate = true;

  weather = {
    enabled = true;
    unit = "celsius";
    effects = true;
  };

  notification = {
    position = "top_right";
    layer = "overlay";
  };

  osd = {
    position = "top_right";
    hide_delay_ms = 2000;
  };

  audio.enable_sounds = false;

  # Control center shortcuts are left at v5's default set (wifi, bluetooth,
  # caffeine, nightlight, notification, power_profile), which is the v4 set
  # minus the wallpaper and performance-mode buttons.

  bar.main = {
    # v4 "simple" bar: full-length, flush to the edge, concave outer corners.
    position = "left";
    background_opacity = 0.93;
    radius = 12;
    margin_ends = 0;
    margin_edge = 0;
    concave_edge_corners = true;
    capsule = true;
    widget_spacing = 6;

    start = [
      "control-center"
      "tray"
      "clock"
      "media"
      "todo"
    ];
    center = [
      "workspaces"
      "launcher"
      "privacy"
    ];
    end = [
      "notifications"
      "battery"
      "volume"
      "brightness"
      "cpu"
      "cpu-temp"
      "ram"
      "clipboard"
      "tailscale"
    ];
  };

  widget = {
    workspaces = {
      label_source = "id";
      max_label_chars = 2;
      labels_only_when_occupied = true;
      hide_when_empty = false;
      focused_color = "primary";
      occupied_color = "secondary";
      empty_color = "secondary";
    };
    clock = {
      format = "{:%H:%M %a, %b %d}";
      vertical_format = "{:%H\n%M\n-\n%d\n%m}";
      tooltip_format = "{:%H:%M %a, %b %d}";
    };
    media = {
      artist_first = true;
      hide_when_no_media = true;
    };
    battery = {
      display_mode = "graphic";
      show_label = false;
    };
    cpu = {
      type = "sysmon";
      stat = "cpu_usage";
    };
    cpu-temp = {
      type = "sysmon";
      stat = "cpu_temp";
    };
    ram = {
      type = "sysmon";
      stat = "ram_used";
    };
    privacy.hide_inactive = false;
    notifications.hide_when_no_unread = false;
    todo.type = "nightwatch75/todo:todo";
    tailscale.type = "davemhammer/tailscale:status";
  };

  # v4's clipper plugin is covered by the built-in clipboard widget, and
  # privacy-indicator by the built-in privacy widget.
  plugins.enabled = [
    "nightwatch75/todo"
    "davemhammer/tailscale"
  ];
}
