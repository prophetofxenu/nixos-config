{
  lib,
  config,
  pkgs,
  ...
}:
let
  # these should ALWAYS be available
  essentialUtils = with pkgs; [
    curl
    git
    htop
    killall
    lm_sensors
    lsof
    pciutils
    unzip
    usbutils
    wget
    zip
  ];

  desktopUtils = with pkgs; essentialUtils ++ [
    btop
    kdePackages.filelight 
    keepassxc
    megasync
    restic
  ];

  serverUtils = with pkgs; essentialUtils ++ [
    btop
    restic
  ];
in
{
  options = {
    xenu.utilities.set = lib.mkOption {
      description = "Predefined utility set to install";
      type = with lib.types; enum [ "essential" "desktop" "server" "none" ];
      default = "essential";
    };
  };

  config = {
    environment.systemPackages =
      if config.xenu.utilities.set == "essential" then essentialUtils else
      if config.xenu.utilities.set == "desktop" then desktopUtils else
      if config.xenu.utilities.set == "server" then serverUtils else
      [];
  };
}
