{ lib, config, options, pkgs, users, ... }:
rec {

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Auto optimize store
  nix.optimise.automatic = true;

  nix.extraOptions = ''
    extra-substituters = https://devenv.cachix.org
    extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
  '';

  # Device management

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
	device = "nodev";
	efiSupport = true;
      };
    };
  };

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 16 * 1024;
  }];

  networking.hostName = "xenu-t14";
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  boot.supportedFilesystems = [ "nfs" ];

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enables touchpad
  services.libinput.enable = true;

  nixpkgs.config.rocmSupport = true;

  environment.systemPackages = with pkgs; [
    curl
    unzip
    wget
    zip
  ];

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  services.openvpn.servers.xenu-pivpn = {
    config = '' config /etc/openvpn-configs/xenu-t14.ovpn '';
    autoStart = false;
    up = ''
      mv /etc/resolv.conf /etc/resolv.conf.backup
      echo 'nameserver 192.168.1.1' > /etc/resolv.conf
    '';
    down = ''
      mv /etc/resolv.conf.backup /etc/resolv.conf
    '';
  };
  services.openvpn.servers.airvpn-eu = {
    config = '' config /etc/openvpn-configs/AirVPN_Europe_UDP-443-Entry3.ovpn '';
    autoStart = false;
  };
  services.openvpn.servers.airvpn-ca = {
    config = '' config /etc/openvpn-configs/AirVPN_Canada_UDP-443-Entry3.ovpn '';
    autoStart = false;
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  hardware.bluetooth.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;


  # Packages

  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;

  programs.firefox.enable = true;
  # emoji won't render properly without this set
  fonts.fontconfig.useEmbeddedBitmaps = true;

  programs.steam.enable = true;

  # User config

  users.users.xenu = {
    isNormalUser = true;
    extraGroups = [
      "dialout" # embedded development
      "wheel" # sudo
    ];
    shell = pkgs.zsh;
    useDefaultShell = false;
    packages = with pkgs; [
      # utilities
      keepassxc
      logseq
      megasync

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

      # dev
      kicad

      # drones
      betaflight-configurator
    ];
  };

  # enable udev rules for platformio
  services.udev.packages = [
    pkgs.platformio-core.udev
    pkgs.openocd
  ];

}
