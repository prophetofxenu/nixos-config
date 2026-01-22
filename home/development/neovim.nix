{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      { plugin = guess-indent-nvim; }
      { plugin = autoclose-nvim; }
    ];

    #extraConfig = ''
    #  set tabstop=8
    #  set softtabstop=0
    #  set shiftwidth=2 smarttab
    #  set expandtab
    #  set smartindent
    #  set backspace=indent,eol,start
    #'';
    extraLuaConfig = ''
      require("guess-indent").setup()
      require("autoclose").setup()
    '';
  };

  programs.git.settings = {
    core.editor = "nvim";
  };
}
