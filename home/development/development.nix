# things that should always be installed for development
{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;

    settings.push = {
      autoSetupRemote = true;
    };

    # set this so we can run basic git commands without
    # needing root
    settings.safe.directory = "/etc/nixos";
  };

  programs.direnv.enable = true;

  home.packages = with pkgs; [
    devenv
  ];
}
