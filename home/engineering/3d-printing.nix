{ pkgs, ... }:
{
  home.packages = with pkgs; [
    freecad
    graphviz # for dependency graph

    orca-slicer
  ];
}

