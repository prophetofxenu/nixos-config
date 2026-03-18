{ config, pkgs, lib, ... }:

{
  nixpkgs.overlays = [
(final: prev: {
  gnutls = prev.gnutls.overrideAttrs (prevAttrs: {
    postPatch = prevAttrs.postPatch + ''
      touch doc/stamp_error_codes
    '';
  });
})  
];
}
