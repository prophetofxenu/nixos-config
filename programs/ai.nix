{ pkgs, lib, config, ... }:
let

  mcpo = with pkgs; python3Packages.buildPythonApplication rec {
    pname = "mcpo";
    version = "0.0.20";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "open-webui";
      repo = "mcpo";
      tag = "v${version}";
      hash = "sha256-tA1KdcfmNPuqPbwE66jRY85tsrOKjPImsxSoGsW5ZD4=";
    };

    build-system = with python3Packages; [ setuptools hatchling ];

    dependencies = with python3Packages; [
       click
       fastapi
       mcp
       mcp
       passlib
       pydantic
       pyjwt
       python-dotenv
       typer
       uvicorn
       watchdog
    ];
  };

  mcp-filesystem-server = with pkgs; buildGoModule rec {
    pname = "mcp-filesystem-server";
    version = "0.11.1";

    src = fetchFromGitHub {
      owner = "mark3labs";
      repo = "mcp-filesystem-server";
      tag = "v${version}";
      hash = "sha256-Vl6aVR7eheHtlmL9LzidhjeAFO7COxAQ9h9Ol6jCLkM=";
    };

    vendorHash = "sha256-Jln72WlZ7gmF7m28lVOjLrmrHck1E+2bB0o6q2N9JR8=";

    meta = {
      description = "Filesystem MCP server written in Go";
      homepage = "sha256-ogAug05ChGLSJ+KvmP5xXreDhkLHau15Wnp0ry7Ck88=";
      license = lib.licenses.mit;
    };
  };

  mcp-nixos = with pkgs; python3Packages.buildPythonApplication rec {
    pname = "mcp-nixos";
    version = "2.3.0";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "utensils";
      repo = "mcp-nixos";
      tag = "v${version}";
      hash = "sha256-ogAug05ChGLSJ+KvmP5xXreDhkLHau15Wnp0ry7Ck88=";
    };

    build-system = with python3Packages; [ setuptools hatchling ];

    dependencies = with python3Packages; [
      beautifulsoup4
      fastmcp
      requests
    ];
  };

in

{
  options = {
    xenu.ai.open-webui.enable = lib.mkEnableOption "Open Web-UI LLM client";
    xenu.ai.ollama.enable = lib.mkEnableOption "Ollama service for local LLM usage"; 

    xenu.ai.mcp.filesystem = lib.mkOption { type = lib.types.bool; default = false; };
    xenu.ai.mcp.nixos = lib.mkOption { type = lib.types.bool; default = false; };
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

    systemd.user.services.mcp-filesystem = lib.mkIf config.xenu.ai.mcp.filesystem {
      after = [ "network.target" ];
      description = "mcp-proxy for mcp-filesystem-server";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${mcpo}/bin/mcpo --port 9090 --api-key 'top-secret' -- ${mcp-filesystem-server}/bin/mcp-filesystem-server /home/xenu/Desktop";
        Restart = "no";
      };
    };

    systemd.user.services.mcp-nixos = lib.mkIf config.xenu.ai.mcp.nixos {
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
        MCP_NIXOS_PORT = "9091";
      };
    };
  };
}
