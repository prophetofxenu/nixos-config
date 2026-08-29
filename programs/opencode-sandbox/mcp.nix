{ pkgs, ... }:
let
  mcp-nixos = pkgs.callPackage ../mcp/mcp-nixos.nix { };
in
{
  systemd.services.mcp-nixos = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    description = "Querying of Nix related databases and docs";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${mcp-nixos}/bin/mcp-nixos";
      Restart = "no";
      User = "opencode";
      Group = "opencode";
    };
    environment = {
      MCP_NIXOS_TRANSPORT = "http";
      MCP_NIXOS_HOST = "127.0.0.1";
      MCP_NIXOS_PORT = "57172";
    };
  };
}
