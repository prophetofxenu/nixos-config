{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      { plugin = ctrlp; }
      { plugin = guess-indent-nvim; }
    ];
    extraConfig = ''
      set tabstop=8
      set softtabstop=0
      set shiftwidth=2 smarttab
      set expandtab
      set smartindent
      set backspace=indent,eol,start
    '';
  };
}
