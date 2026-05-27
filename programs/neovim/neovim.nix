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
      bufferline-nvim
      guess-indent-nvim
      lualine-nvim
      nvim-lspconfig
      nvim-tree-lua
      nvim-web-devicons
      omni-theme-nvim
      plenary-nvim
      telescope-nvim
      telescope-file-browser-nvim
      toggleterm-nvim
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

  environment.systemPackages = with pkgs; [
    fd
    nerd-fonts.hack
    ripgrep
  ];

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
