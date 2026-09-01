{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.gpu =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      config = {
        # AI Tools
        hardware.amdgpu.opencl.enable = true;

        environment.sessionVariables = {
          # Steer native Vulkan apps to the iGPU. Note this filters *after* device
          # enumeration, so it does not stop an app from opening the dGPU render
          # node -- see the Zed bwrap override in dev.nix for that.
          MESA_VK_DEVICE_SELECT = "1002:15bf!";
        };
      };
    };
}
