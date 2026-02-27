{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixos-hardware, home-manager, ... }: {

    ###############
    ## desktops
    ###############

    nixosConfigurations.xenu-q58 = nixpkgs.lib.nixosSystem {
      modules = [
        ./hardware-configurations/q58.nix
        ./desktop/xenu-q58.nix

        ./ai.nix
        ./development/media.nix
        ./gui/plasma.nix
        ./games/vr.nix
        ./im.nix

        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.xenu = ./home/xenu.nix;
        }
      ];
    };

    nixosConfigurations.xenu-t14 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen2

        ./hardware-configurations/t14.nix
        ./desktop/xenu-t14.nix

        ./development/media.nix
        ./gui/plasma.nix
        ./im.nix

        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.xenu = ./home/xenu.nix;
        }

        # ./networking/wireguard-xenu-t14.nix
      ];
    };

    ##############
    ## servers
    ##############

    nixosConfigurations.xenu-nixbuild = nixpkgs.lib.nixosSystem {
      modules = [
        ./hardware-configurations/nixbuild.nix
        ./server/xenu-nixbuild.nix
      ];
    };

    nixosConfigurations.xenu-pitunnel = nixpkgs.lib.nixosSystem {
      modules = [
        {
          nixpkgs.buildPlatform = "x86_64-linux";
          nixpkgs.hostPlatform = "aarch64-linux";
        }

        ./hardware-configurations/pi3.nix
        ./server/xenu-pitunnel.nix
        # TODO remove this once it has been fixed in unstable
        (import ./server/networkmanager-aarch64-fix.nix)

        ./networking/wireguard-server.nix
      ];
    };

  };
}

