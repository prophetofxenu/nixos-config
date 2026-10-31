{
  lib,
  buildDunePackage,
  fetchFromGitHub,
  melange,
}:

buildDunePackage {
  pname = "melange-fetch";
  version = "0.2.0";

  minimalOCamlVersion = "5.1";
  duneVersion = "3";

  src = fetchFromGitHub {
    owner = "melange-community";
    repo = "melange-fetch";
    tag = "0.2.0";
    hash = "sha256-B0D2SMwUMR64S0SQADZ7CHE+z7tUq9GW5yuzBhLwkzA=";
  };

  nativeBuildInputs = [ melange ];
  propagatedBuildInputs = [ melange ];

  meta = {
    description = "Fetch API support for Melange";
    homepage = "https://github.com/melange-community/melange-fetch";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
