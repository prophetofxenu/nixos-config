{ pkgs, programs, users, ... }:
let
  synthwave84 = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "synthwave-vscode";
    publisher = "RobbOwen";
    version = "0.1.20";
    hash = "sha256-J8igs+SQn967OK0PLNZtV9IOJRqwd+q9vmZ+p9eKSoU=";
  };
in
{
  programs.vscode.enable = true;

  users.users.xenu.packages = with pkgs; [
    (vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions = with vscode-extensions; [
        continue.continue
        vscodevim.vim

        # language support
        ziglang.vscode-zig

        # themes
        synthwave84
      ];
    })
  ];
}
