{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgsStable.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # temporary inputs
    nixpkgsKernel_6_18_56.url = "github:NixOS/nixpkgs?rev=764c4eaef7cbff1c8342c9ff01ea6ced7d2b3ccc";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgsStable,
    nixos-hardware,
    home-manager,

    nixpkgsKernel_6_18_56,
    ...
  }:
  let
    pinnedKernelModule = {
      boot.kernelPackages =
        let
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          pkgsKernelPin = nixpkgsKernel_6_18_56.legacyPackages."x86_64-linux";
        in
        assert pkgs.linuxPackages.kernel.version == "6.18.57";
        assert pkgsKernelPin.linuxPackages.kernel.version == "6.18.56";
        pkgsKernelPin.linuxPackages;
    };
  in
  {

    ###############
    ## desktops
    ###############

    nixosConfigurations.xenu-q58 = nixpkgs.lib.nixosSystem {
      modules = [
        { nix.settings.trusted-users = [ "xenu" ]; }
        ./hardware-configurations/q58.nix
        pinnedKernelModule
        ./desktop/xenu-q58/xenu-q58.nix

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
        ./desktop/xenu-t14/xenu-t14.nix
        nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen2

        ./overlays/overlays.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.xenu = ./home/xenu.nix;
        }
      ];
    };

    nixosConfigurations.xenu-lat14 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hardware-configurations/lat14.nix
        ./desktop/xenu-lat14/xenu-lat14.nix

        ./gui/plasma.nix
        ./programs/neovim/neovim.nix
        ./programs/utilities.nix
        {
          xenu.utilities.set = "desktop";
        }
        ./programs/logseq-electron-41.nix
        {
          users.users.xenu.packages = with nixpkgsStable.legacyPackages."x86_64-linux"; [
            freecad
            graphviz
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
        ./programs/opencode-sandbox/container.nix
        {
          xenu.ai.opencode-sandbox.enable = true;
          xenu.ai.opencode-sandbox.containers.test = {
            port = 4096;
            openFirewall = true;
            hostDir = "/mnt/opencode-sandbox";
            envFile = "/home/xenu/opencode.env";
            opencodeConf = {

              mcp = {

                context7 = {
                  enabled = true;
                  type = "remote";
                  url = "https://mcp.context7.com/mcp";
                  headers = {
                    Authorization = "Bearer {env:CONTEXT7_API_KEY}";
                  };
                };

                nixos = {
                  enabled = true;
                  type = "remote";
                  url = "http://127.0.0.1:57172/mcp";
                };

              };

            };
          };
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

