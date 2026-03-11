{ pkgs, lib, config, ... }:
{
  options = {
    xenu.open-webui.enable = lib.mkEnableOption "Open Web-UI LLM client";
    xenu.ollama.enable = lib.mkEnableOption "Ollama service for local LLM usage"; 
  };

  config = {
    services.open-webui = lib.mkIf config.xenu.open-webui.enable {
      enable = true;
      port = 50100;
    };

    services.ollama = lib.mkIf config.xenu.ollama.enable {
      enable = true;
      package = pkgs.ollama-rocm;
    };
  };
}
