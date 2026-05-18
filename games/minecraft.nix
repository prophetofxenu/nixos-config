{ pkgs, ... }:
{
  users.users.xenu.packages = with pkgs; [ prismlauncher ];
}
