{ pkgs, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "castlabs-electron"
      "antigravity"
      "mathematica"
    ];
}
