{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      logseq = pkgs.callPackage ../programs/logseq/package.nix {};
    })
  ];
}
