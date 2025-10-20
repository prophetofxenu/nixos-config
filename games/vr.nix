{ config, lib, pkgs, ... }:
{
  # Monado for OpenXR support
  services.monado = {
    enable = true;
    defaultRuntime = true;
  };
  systemd.user.services.monado.environment = {
    XRT_COMPOSITOR_COMPUTE = "1"; # helps prevent stuttering
    WMR_HANDTRACKING = "0"; # disable hand tracking
  };
}

