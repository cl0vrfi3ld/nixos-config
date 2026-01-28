# system-level ai config
{ config, pkgs, ... }:

{
  hardware.amdgpu.opencl.enable = true;
  services.ollama.enable = true;
  services.ollama.package = pkgs.ollama-rocm;
  services.ollama.environmentVariables = {
    OLLAMA_DEBUG = "1";
    HIP_VISIBLE_DEVICES = "0";
    ROCR_VISIBLE_DEVICES = "0";
  };
  services.open-webui.enable = false;
  services.open-webui.port = 12121;
}
