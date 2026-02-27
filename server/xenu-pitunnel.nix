{ config, lib, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Needed to allow remote builds
  nix.settings.trusted-users = [ "root" "@wheel" ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  swapDevices = [
    {
      device = "/swapfile";
      size = 2048;
    }
  ];

  networking.hostName = "xenu-pitunnel"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.xenu = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      btop
    ];
  };


  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    curl
    dig
    htop
    wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # dynamic DNS
  services.ddns-updater = {
    enable = true;
    environment = {
      CONFIG_FILEPATH = "/etc/ddns-noip.json";
      PERIOD = "5m";
      # needs this or it doesn't work for some reason
      RESOLVER_ADDRESS = "127.0.0.1:53";
    };
  };

  ##################################################
  ## don't change anything below this block idiot ##
  ##################################################

  # This is the initial version from when the config was generated.
  system.stateVersion = "26.05";
}

