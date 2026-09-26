{
  pkgs,
  ...
}:

let
  omni-theme-nvim = (pkgs.callPackage ./omni-theme-nvim.nix { });

  nvimPlugins = pkgs.symlinkJoin {
    name = "neovim-plugins";
    paths = with pkgs.vimPlugins; [
      autoclose-nvim
      blink-cmp
      bufferline-nvim
      gitsigns-nvim
      guess-indent-nvim
      indent-blankline-nvim
      lualine-nvim
      nvim-comment
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

    # LSP
    clang-tools
    nixd
    zls
  ];

  users.users.xenu.packages = [(
    pkgs.writeShellScriptBin "restore-neovim-config" ''
      set -e
      rm -rf $HOME/.config/nvim
      echo "${./nvim} -> $HOME/.config/nvim"
      mkdir $HOME/.config/nvim
      cp -r ${nvimPlugins}/* $HOME/.config/nvim
      cp -r ${./nvim}/* $HOME/.config/nvim
      find $HOME/.config/nvim -type d -exec chmod 755 {} \;
      find $HOME/.config/nvim -type f -exec chmod 644 {} \;
    ''
  )];
}
