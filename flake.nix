{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgsStable.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # added because devenv 2.3.1 has a bug that breaks it, and a fix is not available
    nixpkgsDevenv222.url = "github:NixOS/nixpkgs/bb11e50a8843e245cd8400e1ae3823bd6f64cc9c";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgsStable, nixos-hardware, nixpkgsDevenv222, home-manager, ... }: {

    ###############
    ## desktops
    ###############

    nixosConfigurations.xenu-q58 = nixpkgs.lib.nixosSystem {
      modules = [
        { nix.settings.trusted-users = [ "xenu" ]; }
        ./hardware-configurations/q58.nix
        ./desktop/xenu-q58.nix

        ./desktop/printing.nix
        ./development/media.nix
        ./development/vscodium.nix
        ./gui/plasma.nix
        ./games/minecraft.nix
        ./games/vr.nix
        ./programs/im.nix
        ./programs/neovim/neovim.nix
        ./programs/utilities.nix
        {
          xenu.utilities.set = "desktop";
        }

        ./programs/ai.nix
        {
          xenu.ai.ollama.enable = true;
        }

        {
          users.users.xenu.packages = with nixpkgsStable.legacyPackages."x86_64-linux"; [
            freecad
            graphviz
          ];
        }
        {
          users.users.xenu.packages = with nixpkgsDevenv222.legacyPackages."x86_64-linux"; [
            devenv
          ];
        }

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

        ./desktop/printing.nix
        ./development/media.nix
        ./gui/plasma.nix
        ./programs/im.nix
        ./programs/neovim/neovim.nix
        ./programs/utilities.nix
        {
          xenu.utilities.set = "desktop";
        }

        {
          users.users.xenu.packages = with nixpkgsDevenv222.legacyPackages."x86_64-linux"; [
            devenv
          ];
        }

        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.xenu = ./home/xenu.nix;
        }
      ];
    };

    ##############
    ## servers
    ##############

    nixosConfigurations.xenu-nixbuild = nixpkgs.lib.nixosSystem {
      modules = [
        ./hardware-configurations/nixbuild.nix
        ./server/xenu-nixbuild.nix

        ./programs/utilities.nix
        {
          xenu.utilities.set = "server";
        }
      ];
    };

    nixosConfigurations.xenu-pitunnel = nixpkgsStable.lib.nixosSystem {
      modules = [
        {
          nixpkgs.buildPlatform = "x86_64-linux";
          nixpkgs.hostPlatform = "aarch64-linux";
        }

        ./hardware-configurations/pi3.nix
        ./server/xenu-pitunnel.nix

        ./programs/utilities.nix
        {
          xenu.utilities.set = "server";
        }
        ./networking/wireguard-server.nix
      ];
    };

  };
}

