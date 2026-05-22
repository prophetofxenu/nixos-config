{ lib, pkgs, ... }:
pkgs.vimUtils.buildVimPlugin {
  pname = "omni-theme-nvim";
  version = "0.1";
  src = pkgs.fetchFromGitHub {
    owner = "getomni";
    repo = "neovim";
    rev = "8ade5cd37d12a4868b0ec891aeba88ffea3c4853";
    hash = "sha256-k8u8XPbgs9Y8+bvm078peIRjRJTs6lpLvpYcybkXCZM=";
  };
  meta.homepage = "https://github.com/getomni/neovim";
  meta.license = lib.getLicenseFromSpdxId "MIT";
}
