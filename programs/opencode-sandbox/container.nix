{
  lib,
  pkgs,
  ...
}: {
  containers.ocode-sandbox = {
    ephemeral = true;
    autoStart = false;

    bindMounts."/work" = {
      hostPath = "/mnt/opencode-sandbox";
      isReadOnly = false;
    };

    config = {
      imports = [
        ../ai.nix

        ./mcp.nix
      ];

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
        opencode
        git
      ];

      # Open the opencode port in the container's own firewall (private veth).
      networking.firewall.allowedTCPPorts = [ 4096 ];

      # Make sure workdir exists
      systemd.tmpfiles.rules = [
        "d /work 700 opencode opencode -"
        #"d /home/opencode/.config/opencode 700 opencode opencode -"
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
          # `-` makes the env file optional: present only when the launcher
          # bind-mounts one with OPENCODE_SERVER_PASSWORD.
          EnvironmentFile = "-/run/opencode/server.env";
          ExecStart = "${lib.getExe pkgs.opencode} serve --hostname 0.0.0.0 --port 4096";
        };
      };
    };
  };
}
