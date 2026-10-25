{
  pkgs,
  ...
}:
{
  imports = [ ../../programs/opencode-sandbox/container.nix ];

  xenu.ai.opencode-sandbox.enable = true;
  xenu.ai.opencode-sandbox.containers."lepi-labs" = {
    port = 5000;
    hostDir = "/mnt/opencode-sandbox/lepi-labs";
    envFile = "/home/xenu/.config/opencode-sandbox/opencode-lepi-labs.env";
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
