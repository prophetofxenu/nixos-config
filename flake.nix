{
  inputs = {
    # This is pointing to an unstable release.
    # If you prefer a stable release instead, you can this to the latest number shown here: https://nixos.org/download
    # i.e. nixos-24.11
    # Use `nix flake update` to update the flake to the latest revision of the chosen release channel.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = inputs@{ self, nixpkgs, ... }: {

    nixosConfigurations.xenu-q58 = nixpkgs.lib.nixosSystem {
      modules = [
        ./base-configs/q58-configuration.nix

        ./desktop/xenu-q58.nix
        ./gui/plasma.nix
        ./games/vr.nix
      ];
    };

    nixosConfigurations.xenu-t14 = nixpkgs.lib.nixosSystem {
      modules = [
        ./base-configs/t14-configuration.nix

        ./desktop/xenu-t14.nix
        ./gui/plasma.nix
      ];
    };

  };
}

