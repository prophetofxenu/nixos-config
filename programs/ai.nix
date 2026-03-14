{ pkgs, lib, config, ... }:
let

  mcp-proxy = with pkgs; python3Packages.buildPythonApplication rec {
    pname = "mcp-proxy";
    version = "0.11.0";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "sparfenyuk";
      repo = "mcp-proxy";
      tag = "v${version}";
      hash = "sha256-oSRchkCnPoQ3KZXPW49O2yTgNRi9aJbKki3z9BxBPhA=";
    };

    build-system = with python3Packages; [ setuptools ];
    
    dependencies = with python3Packages; [ httpx-auth mcp uvicorn ];
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
      homepage = "";
      license = lib.licenses.mit;
    };
  };

in
{
  options = {
    xenu.ai.open-webui.enable = lib.mkEnableOption "Open Web-UI LLM client";
    xenu.ai.ollama.enable = lib.mkEnableOption "Ollama service for local LLM usage"; 

    xenu.ai.mcp.filesystem = lib.mkOption {
      type = lib.types.bool;
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

    systemd.user.services.mcp-proxy = lib.mkIf xenu.ai.mcp.filesystem {
      enable = false;
      after = [ "network.target" ];
      description = "My proxy service for stdio MCP servers";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${mcp-proxy}/bin/mcp-proxy";
      };
    };
  };
}
