{
  lib,
  buildDunePackage,
  fetchurl,
  melange,
}:

buildDunePackage {
  pname = "melange-fest";
  version = "0.2.0";

  minimalOCamlVersion = "5.1";
  duneVersion = "3";

  src = fetchurl {
    url = "https://github.com/ahrefs/melange-fest/releases/download/0.2.0/melange-fest-0.2.0.tbz";
    hash = "sha256-n1eOy5vBhaW6uYO1msCKoHm9QQWPGdPpAtlP31UvnIg=";
  };

  # ships a dune-workspace with multiple build contexts, which breaks
  # `dune install --prefix` ("Cannot specify '--prefix' ... multiple contexts")
  postPatch = ''
    rm -f dune-workspace
  '';

  nativeBuildInputs = [ melange ];
  propagatedBuildInputs = [ melange ];

  meta = {
    description = "A minimal test framework for Melange";
    homepage = "https://github.com/ahrefs/melange-fest";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
