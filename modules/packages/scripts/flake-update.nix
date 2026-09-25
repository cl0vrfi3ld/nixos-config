{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.flake-update = pkgs.writeShellApplication {
        name = "flake-update";
        runtimeInputs = [ pkgs.jq ];
        text = ''
          usage() {
            printf '%s\n' \
              "Usage: flake-update [-g] <group> [[-g] <group>...] [-c] [--list] [-- <nix args>]" \
              "       flake-update --list" \
              "" \
              "  [-g, --group] <group>  update every input in <group> (repeatable; -g is optional)" \
              "  -c, --commit           commit flake.lock after updating (nix --commit-lock-file)" \
              "  -l, --list             print groups (or the selected groups' inputs) without updating" \
              "  --                     pass remaining args to nix flake update" \
              "" \
              "Groups are read from <flake>#meta.inputGroups." \
              "Flake: \$NH_FLAKE if set, else the current directory."
          }

          flake="''${NH_FLAKE:-$PWD}"
          groups=()
          list=0
          commit_args=()
          nix_args=()

          while [ $# -gt 0 ]; do
            case "$1" in
              -g|--group)
                [ $# -ge 2 ] || { echo "error: --group needs an argument" >&2; exit 2; }
                groups+=("$2"); shift 2 ;;
              -l|--list) list=1; shift ;;
              -c|--commit) commit_args=(--commit-lock-file); shift ;;
              -h|--help) usage; exit 0 ;;
              --) shift; nix_args=("$@"); break ;;
              -*) echo "error: unknown argument: $1" >&2; usage >&2; exit 2 ;;
              *) groups+=("$1"); shift ;;
            esac
          done

          if [ ''${#groups[@]} -eq 0 ] && [ "$list" -eq 0 ]; then
            usage >&2; exit 2
          fi

          json="$(nix eval --json "$flake#meta.inputGroups")"

          if [ ''${#groups[@]} -eq 0 ]; then
            jq -r 'to_entries[] | "\(.key): \(.value | join(" "))"' <<<"$json"
            exit 0
          fi

          inputs=()
          for g in "''${groups[@]}"; do
            if ! jq -e --arg g "$g" 'has($g)' <<<"$json" >/dev/null; then
              echo "error: unknown group '$g' (have: $(jq -r 'keys | join(", ")' <<<"$json"))" >&2
              exit 1
            fi
            mapfile -t -O "''${#inputs[@]}" inputs < <(jq -r --arg g "$g" '.[$g][]' <<<"$json")
          done

          # dedupe, preserving order
          mapfile -t inputs < <(printf '%s\n' "''${inputs[@]}" | awk '!seen[$0]++')

          if [ "$list" -eq 1 ]; then
            printf '%s\n' "''${inputs[@]}"
            exit 0
          fi

          echo "updating: ''${inputs[*]}" >&2
          exec nix flake update --flake "$flake" "''${inputs[@]}" "''${commit_args[@]}" "''${nix_args[@]}"
        '';
      };
    };
}
