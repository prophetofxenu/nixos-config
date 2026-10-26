{
  ...
}:
{
  nixpkgs.overlays = [
    (final: prev: {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (python-final: python-prev: {
          fastmcp-slim = python-prev.fastmcp-slim.override {
            mcp = python-final.mcp_1;
          };
        })
      ];
    })
  ];
}
