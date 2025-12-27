{ config, pkgs, ... }:

{
  home.username = "xenu";
  home.homeDirectory = "/home/xenu";

  programs.zsh = {
    # login shell needs to be set in system config
    enable = true;

    enableCompletion = true;
    syntaxHighlighting.enable = true;
    history.ignoreAllDups = true;

    shellAliases = {
      ll = "ls -l";
      lla = "ls -la";

      suvim = "sudo vim";
      gosys = "cd /etc/nixos";
      vimsys = "sudo vim /etc/nixos";
      upd8 = "sudo nixos-rebuild switch --flake /etc/nixos";
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = ./zsh;
        file = "p10k.zsh";
      }
    ];
  };

  programs.git = {
    enable = true;
    lfs.enable = true;

    settings.push = {
      autoSetupRemote = true;
    };

    settings.safe.directory = "/etc/nixos";
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
