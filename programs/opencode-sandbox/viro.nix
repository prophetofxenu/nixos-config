{
  provider = {
    viro = {
      npm = "@ai-sdk/openai-compatible";
      name = "Viro";
      options = {
        baseURL = "https://api.viro.app/v1";
        apiKey = "{env:VIRO_API_KEY}";
      };
      models = {
        "viro/optimized" = { name = "Viro Optimized"; };
        "viro/clean" = { name = "Viro Clean"; };
        "viro/kimi-k3" = { name = "Kimi K3"; };
        "viro/glm-5.3" = { name = "GLM-5.3"; };
        "viro/glm-5.3-flash" = { name = "GLM-5.3 Flash"; };
      };
    };
  };
}
