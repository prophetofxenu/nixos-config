{ pkgs, services, ... }:
rec {
  services.ollama.enable = true;
  services.ollama.package = pkgs.ollama-rocm;

  services.open-webui.enable = true;
  services.open-webui.port = 50100;
}
