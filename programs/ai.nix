{ pkgs, lib, config, ... }:
let
  mcpo = pkgs.callPackage ./mcp/mcpo.nix { };
  mcp-filesystem-server = pkgs.callPackage ./mcp/mcp-filesystem-server.nix { };
  mcp-nixos = pkgs.callPackage ./mcp/mcp-nixos.nix { };
in
{
  options = {
    xenu.ai.open-webui.enable = lib.mkEnableOption "Open Web-UI LLM client";
    xenu.ai.ollama.enable = lib.mkEnableOption "Ollama service for local LLM usage"; 

    xenu.ai.mcp.filesystem.enable = lib.mkEnableOption "Enables MCP server for restricted filesystem access.";
    xenu.ai.mcp.filesystem.port = lib.mkOption {
      description = "Port to host the streamable HTTP server on.";
      type = with lib.types; port;
      default = 57171;
    };
    xenu.ai.mcp.filesystem.apiKey = lib.mkOption {
      description = "API key required to access the server.";
      type = with lib.types; str;
    };
    xenu.ai.mcp.filesystem.allowedDirectories = lib.mkOption {
      description = "Allowed directories to give models access to.";
      type = with lib.types; listOf str;
      default = [];
    };

    xenu.ai.mcp.nixos.enable = lib.mkEnableOption "Enables MCP server for discovery of NixOS packages, options, and documenation";
    xenu.ai.mcp.nixos.port = lib.mkOption {
      description = "Port to host the streamable HTTP server on.";
      type = with lib.types; port;
      default = 57172;
    };
  };

  config = {
    services.open-webui = lib.mkIf config.xenu.ai.open-webui.enable {
      enable = true;
      port = 50100;
    };

    services.ollama = lib.mkIf config.xenu.ai.ollama.enable {
      enable = true;
      package = pkgs.ollama-rocm;
    };

    systemd.user.services.mcp-filesystem = lib.mkIf config.xenu.ai.mcp.filesystem.enable {
      after = [ "network.target" ];
      description = "mcp-proxy for mcp-filesystem-server";
      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          ${mcpo}/bin/mcpo \
            --port ${toString config.xenu.ai.mcp.filesystem.port} \
            --api-key ${config.xenu.ai.mcp.filesystem.apiKey} \
            -- \
            ${mcp-filesystem-server}/bin/mcp-filesystem-server \
            ${toString config.xenu.ai.mcp.filesystem.allowedDirectories}
        '';
        Restart = "no";
      };
    };

    systemd.user.services.mcp-nixos = lib.mkIf config.xenu.ai.mcp.nixos.enable {
      after = [ "network.target" ];
      description = "Querying of Nix related databases and docs";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${mcp-nixos}/bin/mcp-nixos";
        Restart = "no";
      };
      environment = {
        MCP_NIXOS_TRANSPORT = "http";
        MCP_NIXOS_HOST = "127.0.0.1";
        MCP_NIXOS_PORT = toString config.xenu.ai.mcp.nixos.port;
      };
    };
  };
}
