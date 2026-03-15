{ pkgs, lib, ... }:
with pkgs; python3Packages.buildPythonApplication rec {
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
}
