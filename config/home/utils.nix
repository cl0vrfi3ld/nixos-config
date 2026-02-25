{ pkgs, inputs, system, ... }:

let
  selfprivacy-app = inputs.self-privacy.packages.${system}.release;
in
{
  home.packages = with pkgs; [
    gearlever
    usbimager
    wl-clipboard
    selfprivacy-app
    btop-rocm
  ];
}
