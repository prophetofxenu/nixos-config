{ pkgs, users, ... }:
{
  users.users.xenu.packages = with pkgs; [
    blender
    darktable
    inkscape
    krita
    pureref
  ];
}
