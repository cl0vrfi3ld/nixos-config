{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kdePackages.kate
    nixd
    nixfmt
    nodejs
    bun
    forgejo-cli
    shellcheck
    shfmt
    antigravity-fhs
  ];
}
