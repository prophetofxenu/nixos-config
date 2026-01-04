{ config, pkgs, ... }:

{
  home.username = "xenu";
  home.homeDirectory = "/home/xenu";

  imports = [
    ./zsh/zsh.nix

    ./development/development.nix
    ./development/neovim.nix
    ./development/vscode/vscode.nix

    ./engineering/3d-printing.nix
  ];

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
