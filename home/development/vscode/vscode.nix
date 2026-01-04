# basic VS Code configuration
{ pkgs, ... }:

let
defaultSettings = {
  workbench.colorTheme = "Monokai";
  git.autofetch = true;
  editor.rulers = [
    { column = 120; }
  ];

  vim.handleKeys = {
    "<C-p>" = false;
    "<C-b>" = false;
    "<C-j>" = false;
    "<C-d>" = true;
    "<C-s>" = false;
    "<C-z>" = false;
  };
};

defaultKeybindings = [
  { key = "ctrl+tab c"; command = "github.copilot.chat.completions.toggle"; }
];

defaultExtensions = with pkgs.vscode-extensions; [
  mkhl.direnv
  vscodevim.vim
  wakatime.vscode-wakatime
];

in
{
  programs.vscode.enable = true;

  #programs.vscode.profiles.default = {
  #  userSettings = defaultSettings;
  #  keybindings = defaultKeybindings;

  #  extensions = with pkgs.vscode-extensions; defaultExtensions ++ [
  #    github.copilot
  #    github.copilot-chat
  #  ];
  #};

  #programs.vscode.profiles.webdev = {
  #  userSettings = defaultSettings;
  #  keybindings = defaultKeybindings;

  #  extensions = with pkgs.vscode-extensions; defaultExtensions ++ [
  #    github.copilot
  #    github.copilot-chat

  #    bradlc.vscode-tailwindcss
  #    dbaeumer.vscode-eslint
  #  ];
  #};
}
