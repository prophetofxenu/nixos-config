{ pkgs, lib, config, ... }:
let
  mcpo = pkgs.callPackage ./mcp/mcpo.nix { };
  mcp-filesystem-server = pkgs.callPackage ./mcp/mcp-filesystem-server.nix { };
  mcp-logseq = pkgs.callPackage ./mcp/mcp-logseq.nix { };
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

    xenu.ai.mcp.logseq = {
      enable = lib.mkEnableOption "Enables MCP server for interacting with Logseq notes.";
      logseqUrl = lib.mkOption {
        description = "URL at which Logseq is running.";
        type = with lib.types; str;
        default = "http://localhost:12315";
      };
      logseqApiKey = lib.mkOption {
        description = "API key created in Logseq for granting access."; 
        type = with lib.types; str;
      };
      mcpApiKey = lib.mkOption {
        description = "API key required to access the MCP server.";
        type = with lib.types; str;
      };
      port = lib.mkOption {
        description = "Port to host MCP server on.";
        type = with lib.types; port;
        default = 57173;
      };
    };

    xenu.ai.mcp.nixos.enable = lib.mkEnableOption "Enables MCP server for discovery of NixOS packages, options, and documenation.";
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
            -h localhost \
            --port ${toString config.xenu.ai.mcp.filesystem.port} \
            --api-key ${config.xenu.ai.mcp.filesystem.apiKey} \
            -- \
            ${mcp-filesystem-server}/bin/mcp-filesystem-server \
            ${toString config.xenu.ai.mcp.filesystem.allowedDirectories}
        '';
        Restart = "no";
      };
    };

    systemd.user.services.mcp-logseq = lib.mkIf config.xenu.ai.mcp.logseq.enable {
      after = [ "network.target" ];
      description = "mcp-proxy for mcp-logseq";
      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          ${mcpo}/bin/mcpo \
            -h localhost \
            --port ${toString config.xenu.ai.mcp.logseq.port} \
            --api-key ${config.xenu.ai.mcp.logseq.mcpApiKey} \
            -- \
            ${mcp-logseq}/bin/mcp-logseq
        '';
      };
      environment = {
        LOGSEQ_API_TOKEN = config.xenu.ai.mcp.logseq.logseqApiKey;
        LOGSEQ_API_URL = config.xenu.ai.mcp.logseq.logseqUrl;
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
