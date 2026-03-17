{ pkgs, lib, ... }:
with pkgs; python3Packages.buildPythonApplication rec {
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
}
