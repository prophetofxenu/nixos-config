{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    freecad
    graphviz # for freecad dependecy graph
    orcaslicer
  ];
}

