{
  libs,
  pkgs,
  ...
}:

let
  omni-theme-nvim = (pkgs.callPackage ./omni-theme-nvim.nix { });

  nvimPlugins = pkgs.symlinkJoin {
    name = "neovim-plugins";
    paths = with pkgs.vimPlugins; [
      guess-indent-nvim
      omni-theme-nvim
    ];
  };
in

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
      echo "${./nvim} -> $HOME/.config/nvim"
      cp -r ${./nvim} $HOME/.config/nvim
      chmod 744 -R $HOME/.config/nvim
      cp -r ${nvimPlugins}/lua/* $HOME/.config/nvim/lua
      chmod 744 -R $HOME/.config/nvim
    ''
  )];
}
