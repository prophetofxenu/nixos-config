{ config, pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    (final: prev:
     {
     networkmanager = prev.networkmanager.overrideAttrs (oldAttrs: {

         mesonFlags = prev.networkmanager.mesonFlags ++ [
         "-Dman=${prev.lib.boolToString (prev.stdenv.buildPlatform == prev.stdenv.hostPlatform)}"
         ];

         });
     })
  ];
}
