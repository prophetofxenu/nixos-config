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
    tmux
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

  maintenanceScript = pkgs.writeShellScriptBin "maintenance"
  ''
    read -p "Remove all but the last 3 generations? "
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      sudo nix-env --delete-generations +3
      echo 'Deleted old generations'
    fi

    echo 'Cleaning Nix store'
    sudo nix-collect-garbage
    echo 'Cleaning /boot'
    sudo /run/current-system/bin/switch-to-configuration boot

    read -p 'Clean Docker? '
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      docker image prune --all
      docker system prune -a
    fi

    echo 'Cleaning systemd journal'
    sudo journalctl --vacuum-size=50M
  '';
in
{
  options = {
    xenu.utilities.set = lib.mkOption {
      description = "Predefined utility set to install";
      type = with lib.types; enum [ "essential" "desktop" "server" "none" ];
      default = "essential";
    };

    xenu.utilities.includeMaintenanceScript = lib.mkOption {
      description = "maintenance shell script";
      type = with lib.types; bool;
      default = true;
    };
  };

  config = {
    environment.systemPackages =
      (
        if config.xenu.utilities.set == "essential" then essentialUtils else
        if config.xenu.utilities.set == "desktop" then desktopUtils else
        if config.xenu.utilities.set == "server" then serverUtils else
        []
      ) ++ (
        if config.xenu.utilities.includeMaintenanceScript then [ maintenanceScript ] else []
      );
  };
}
