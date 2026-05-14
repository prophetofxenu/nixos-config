{ libs, pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  users.users.xenu.packages = [(
    pkgs.writeShellScriptBin "restore-neovim-config" ''
      rm -rf $HOME/.config/nvim
      cp -r ./nvim $HOME/.config/nvim
    ''
  )];
}
