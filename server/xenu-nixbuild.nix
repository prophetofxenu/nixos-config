{ config, lib, pkgs, ... }:

{
  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 32 * 1024;
  }];

  networking.hostName = "xenu-nixbuild"; # Define your hostname.

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
      htop
      tree
    ];
  };

  # programs.firefox.enable = true;
  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    tmux
    vim
    wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;


  ##################################################
  ## don't change anything below this block idiot ##
  ##################################################

  # This is the initial version from when the config was generated.
  system.stateVersion = "25.11";
}

