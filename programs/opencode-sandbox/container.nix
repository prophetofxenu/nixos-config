{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.xenu.ai.opencode-sandbox;
in
{

  options.xenu.ai.opencode-sandbox = {

    enable = lib.mkEnableOption "Enable OpenCode sandbox containers.";

    containers = lib.options.mkOption {
      type = lib.types.attrsOf (lib.types.submodule (
        { name, ... }:
        {
          options = {

            containerName = lib.options.mkOption {
              type = lib.types.str;
              default = name;
              description = "The name of the container.";
            };

            port = lib.options.mkOption {
              type = lib.types.port;
              default = 4096;
              description = "Port to run OpenCode on. This will be exposed through the container so the host client can connect.";
            };

            additionalPorts = lib.options.mkOption {
              type = lib.types.listOf lib.types.port;
              default = [];
              description = "Additional ports to expose between the container and host.";
            };

            openFirewall = lib.options.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Open the exposed ports (OpenCode and additional ports) on the host's firewall, for allowing external connections.";
            };

            hostDir = lib.options.mkOption {
              type = lib.types.str;
              description = "A path on the host to bind mount, serving as the workspace.";
            };

            packages = lib.options.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
              description = "Extra packages to include in the container's systemPackages.";
            };

            opencodeConf = lib.options.mkOption {
              type = lib.types.attrs;
              default = {};
              description = "The OpenCode config, serialized from an attr set to opencode.jsonc";
            };

            envFile = lib.options.mkOption {
              type = lib.types.str;
              description = "An environment file to make available to the OpenCode process. This can be used for providing model and API keys.";
              default = "";
            };

          };
        }
      ));
    };
  };

  config = lib.mkIf cfg.enable {

    # ensure the host dirs exist
    # assertions = 
    #   let
    #
    #     hostDirSet = lib.mapAttrsToList (name: inst: {
    #       assertion = inst.hostDir != null;
    #       message = "No host directory set for container ${name}.";
    #     }) cfg.containers;
    #
    #     hostDirExists = lib.mapAttrsToList (name: inst: {
    #       assertion = builtins.pathExists inst.hostDir; 
    #       message = "Host directory ${inst.hostDir} does not exist.";
    #       }) cfg.containers;
    #
    #   in
    #     hostDirSet ++ hostDirExists;

    # networking.firewall.allowedTCPPorts =
    #   if cfg.openFirewall then [ cfg.port ] ++ cfg.additionalPorts else [];

    containers = lib.mapAttrs (name: inst: {
      ephemeral = true;
      autoStart = false;

      bindMounts."/work" = {
        hostPath = inst.hostDir;
        isReadOnly = false;
      };

      bindMounts."/run/opencode/server.env" = lib.mkIf (inst.envFile != "") {
        hostPath = inst.envFile;
        isReadOnly = true;
      };

      config = {
        imports = [
          ../ai.nix

          ./mcp.nix
        ];

        nix.settings.experimental-features = [ "nix-command" "flakes" ];
        # needed for devenv
        nix.extraOptions = ''
          extra-substituters = https://devenv.cachix.org
          extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
        '';

        boot.isNspawnContainer = true;
        networking.useDHCP = false;
        system.stateVersion = lib.trivial.release; # match the nixpkgs we import

        # Non-root user that runs the opencode server.
        users.groups.opencode = {};
        users.users.opencode = {
          isNormalUser = true;
          home = "/home/opencode";
          createHome = true;
          group = "opencode";
          uid = 1000;
        };

        # Tools opencode relies on for snapshots/diffs/vcs.
        environment.systemPackages = with pkgs; [
          devenv
          git
          opencode
        ] ++ inst.packages;

        # Open the opencode port in the container's own firewall (private veth).
        networking.firewall.allowedTCPPorts = [ inst.port ] ++ inst.additionalPorts;

        # Make sure workdir exists
        systemd.tmpfiles.rules = [
          "d /work 700 opencode opencode -"
        ];

        # The opencode HTTP server, run as the non-root `opencode` user.
        systemd.services.opencode = {
          wantedBy = ["multi-user.target"];
          after = ["network-online.target"];
          wants = ["network-online.target"];
          environment.HOME = "/home/opencode";
          environment.OPENCODE_CONFIG = pkgs.writeText "opencode.jsonc" (lib.fileContents ./opencode.jsonc);
          serviceConfig = {
            User = "opencode";
            Group = "opencode";
            WorkingDirectory = "/work";
            Restart = "on-failure";
            # `-` makes the env file optional in case it wasn't mounted
            EnvironmentFile = "-/run/opencode/server.env";
            ExecStart = "${lib.getExe pkgs.opencode} serve --hostname 0.0.0.0 --port ${toString inst.port}";
          };
        };
      };
    }) cfg.containers;
  };

}
