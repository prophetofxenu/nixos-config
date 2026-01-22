{ lib, config, options, pkgs, users, ... }:
rec {

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Device management

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
	useOSProber = false;
      };
    };
  };

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 16 * 1024;
  }];

  networking.hostName = "xenu-q58";
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      4200 # for accessing Angular dev site from other devices on LAN
    ];
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # acpitz is used to shut down the system if thermals are too high. However, on the X570, this sensor seems to be broken.
  # So, disable it at boot.
  # https://forum.manjaro.org/t/acpi-thermal-limit-triggers-thermal-shutdown-on-sleep/154502/16
  systemd.services.disable-broken-thermal = {
    description = "Disable broken acpitz protection";
    wantedBy = [ "multi-user.target" ];
    script = ''
      #!/usr/bin/env sh
      echo disabled > /sys/class/thermal/thermal_zone2/mode
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    curl
    killall
    lm_sensors
    lsof
    unzip
    wget
    zip
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };


  # eve shares
  fileSystems."/mnt/eve/backup" = {
    device = "eve.lan:/mnt/main/encrypt/backup";
    fsType = "nfs";
    options = [ "x-systemd.automount" "user" "noatime" "noauto" "x-systemd.idle-timeout=600" ];
  };
  fileSystems."/mnt/eve/media" = {
    device = "eve.lan:/mnt/main/encrypt/media";
    fsType = "nfs";
    options = [ "x-systemd.automount" "user" "noatime" "noauto" "x-systemd.idle-timeout=600" ];
  };
  fileSystems."/mnt/eve/personal" = {
    device = "eve.lan:/mnt/main/encrypt/personal";
    fsType = "nfs";
    options = [ "x-systemd.automount" "user" "noatime" "noauto" "x-systemd.idle-timeout=600" ];
  };
  fileSystems."/mnt/eve/random" = {
    device = "eve.lan:/mnt/main/random";
    fsType = "nfs";
    options = [ "x-systemd.automount" "user" "noatime" "noauto" "x-systemd.idle-timeout=600" ];
  };
  fileSystems."/mnt/eve/work" = {
    device = "eve.lan:/mnt/main/encrypt/work";
    fsType = "nfs";
    options = [ "x-systemd.automount" "user" "noatime" "noauto" "x-systemd.idle-timeout=600" ];
  };
  boot.supportedFilesystems = [ "nfs" ];


  # Backups

  services.restic.backups.main = {
    paths = [
      "/etc/nixos"

      "/home/xenu/Desktop"
      "/home/xenu/Documents"
      "/home/xenu/Downloads"
      "/home/xenu/Music"
      "/home/xenu/Pictures"
      "/home/xenu/Videos"

      "/home/xenu/MEGA"

      "/home/xenu/.bash_profile"
      "/home/xenu/.bashrc"
      "/home/xenu/.gitconfig"
      "/home/xenu/.gnupg"
      "/home/xenu/.logseq"
      "/home/xenu/.ssh"
      "/home/xenu/.vscode"
    ];

    repository = "/mnt/eve/backup/restic";
    passwordFile = "/etc/nixos/secrets/restic-password";

    timerConfig = {
      OnCalendar = "08:00";
      Persistent = true; # will catch up if computer wasn't running at 8am
    };
    inhibitsSleep = true;
  };


  # Packages

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.rocmSupport = true;

  programs.zsh.enable = true;

  programs.firefox.enable = true;

  programs.gamemode.enable = true;
  programs.steam.enable = true;

  # User config

  users.users.xenu = {
    isNormalUser = true;
    extraGroups = [ "dialout" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      # utilities
      kdePackages.filelight
      keepassxc
      liquidctl
      logseq
      megasync
      restic

      # internet
      chromium

      # messaging
      discord
      signal-desktop
      simplex-chat-desktop
      telegram-desktop

      # media
      strawberry
      vlc

      # media dev
      blender
      godot
      inkscape
      krita
      pureref

      # dev
      kicad

      # fun
      libreoffice-qt
      hunspell
      hunspellDicts.en_US
    ];
  };

  # udev rules for platformio
  services.udev.packages = with pkgs; [
    platformio-core.udev
    openocd
  ];

  # needed for devenv
  nix.extraOptions = ''
    extra-substituters = https://devenv.cachix.org
    extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
  '';

}
