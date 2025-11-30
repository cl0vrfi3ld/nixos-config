# proxy config
{ config, pkgs, ... }:
{
  programs.proxychains.enable = true;
  programs.proxychains.proxies = {
    tetherfi-ethernet-socks5 = {
      type = "socks5";
      host = "172.26.115.147";
      port = 8229;
    };
    tetherfi-ethernet-http = {
      type = "http";
      host = "172.26.115.147";
      port = 8228;
    };
  };

  programs.proxychains.proxies.tetherfi-ethernet-socks5.enable = true;
  programs.proxychains.proxies.tetherfi-ethernet-http.enable = true;
}
