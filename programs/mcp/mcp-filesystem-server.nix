{ pkgs, lib, ... }:
with pkgs; buildGoModule rec {
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
    homepage = "sha256-ogAug05ChGLSJ+KvmP5xXreDhkLHau15Wnp0ry7Ck88=";
    license = lib.licenses.mit;
  };
}
