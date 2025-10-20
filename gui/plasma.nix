{ config, lib, pkgs, ... }:
{
  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
  };

  # Apply a fix for Steam's cursor, otherwise it uses an ugly default.
  programs.steam.extraPackages = with pkgs; [ kdePackages.breeze ];
}
