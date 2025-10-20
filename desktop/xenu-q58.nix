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

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    curl
    git
    git-lfs
    htop
    killall
    lm_sensors
    lsof
    vim
    wget
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;


  # eve shares
  fileSystems."/mnt/eve/backup" = {
    device = "eve.lan:/mnt/main/backup";
    fsType = "nfs";
    options = [ "x-systemd.automount" "user" "noatime" "noauto" "x-systemd.idle-timeout=600" ];
  };
  fileSystems."/mnt/eve/media" = {
    device = "eve.lan:/mnt/main/media";
    fsType = "nfs";
    options = [ "x-systemd.automount" "user" "noatime" "noauto" "x-systemd.idle-timeout=600" ];
  };
  fileSystems."/mnt/eve/personal" = {
    device = "eve.lan:/mnt/main/personal";
    fsType = "nfs";
    options = [ "x-systemd.automount" "user" "noatime" "noauto" "x-systemd.idle-timeout=600" ];
  };
  fileSystems."/mnt/eve/random" = {
    device = "eve.lan:/mnt/main/random";
    fsType = "nfs";
    options = [ "x-systemd.automount" "user" "noatime" "noauto" "x-systemd.idle-timeout=600" ];
  };
  fileSystems."/mnt/eve/work" = {
    device = "eve.lan:/mnt/main/work";
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
  nixpkgs.config.android_sdk.accept_license = true;

  programs.direnv.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    configure = {
      packages.xenu = with pkgs.vimPlugins; {
        start = [ ctrlp guess-indent-nvim ];
      };
    };
  };


  programs.firefox.enable = true;

  programs.gamemode.enable = true;
  programs.steam.enable = true;

  # User config

  users.users.xenu = {
    isNormalUser = true;
    extraGroups = [ "dialout" "wheel" ];
    packages = with pkgs; [
      # utilities
      btop
      devenv
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
      spotify
      strawberry
      vlc

      # media dev
      blender-hip
      inkscape
      krita
      pureref

      # dev
      freecad-wayland
      graphviz
      godot
      kicad
      orca-slicer
      vscode

      # fun
      libreoffice-qt
      hunspell
      hunspellDicts.en_US
    ];
  };

  # needed for devenv
  nix.extraOptions = ''
    extra-substituters = https://devenv.cachix.org
    extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
  '';

}
