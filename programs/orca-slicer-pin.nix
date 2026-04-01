{ lib, pkgs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      orca-slicer = prev.orca-slicer.overrideAttrs (oldAttrs: {
        version = "2.3.1";
        src = final.fetchFromGitHub {
          owner = "SoftFever";
          repo = "OrcaSlicer";
          tag = "v2.3.1";
          hash = "sha256-ua5ZcOnJ8oeY/g6dM9088lYdPNalWLYnD3DNDnw3Q5E=";
        };

        cmakeFlags = oldAttrs.cmakeFlags ++ [
          (lib.cmakeFeature "LIBNOISE_LIBRARY" "${final.libnoise}/lib/libnoise-static.a")
          (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.13")
        ];
      });
    })
  ];
}
