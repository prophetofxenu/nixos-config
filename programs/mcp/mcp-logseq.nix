{ lib, pkgs, ... }:
with pkgs; python3Packages.buildPythonApplication rec {
  pname = "mcp-logseq";
  version = "1.4.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ergut";
    repo = "mcp-logseq";
    tag = "v${version}";
    hash = "sha256-zFpIgbkTeqg8pC342PBsD+XlFWJrlF451TU/7SeNxQ4=";
  };

  build-system = with python3Packages; [ setuptools hatchling ];
  dependencies = with python3Packages; [
    mcp
    python-dotenv
    pyyaml
    requests
  ];
}
