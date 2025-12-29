{ pkgs, ... }:
{
  programs.zsh = {
    # login shell needs to be set in system config
    enable = true;

    enableCompletion = true;
    syntaxHighlighting.enable = true;
    history.ignoreAllDups = true;

    shellAliases = {
      ll = "ls -l";
      lla = "ls -la";

      vi = "nvim";
      vim = "nvim";
      suvim = "sudo nvim";
      gosys = "cd /etc/nixos";
      vimsys = "sudo nvim /etc/nixos";
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
        src = ../zsh;
        file = "p10k.zsh";
      }
    ];
  };
}
