{ pkgs, users, ...}:
{
  users.users.xenu.packages = with pkgs; [
    discord
    element-desktop
    signal-desktop
    simplex-chat-desktop
    telegram-desktop
  ];
}
