{
  ...
}:
{
  imports = [ ../../programs/opencode-sandbox/container.nix ];

  xenu.ai.opencode-sandbox.enable = true;
  xenu.ai.opencode-sandbox.containers."main" = {
    port = 5000;
    hostDir = "/mnt/opencode-sandbox/main";
    envFile = "/home/xenu/.config/opencode-sandbox/opencode-main.env";
    opencodeConf = {
      provider = (import ../../programs/opencode-sandbox/viro.nix).provider;
      model = "viro/optimized";
      small_model = "viro/clean";

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
