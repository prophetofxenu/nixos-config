{
  lib,
  buildDunePackage,
  fetchFromGitHub,
  melange,
  melange-edn,
}:

# Builds both the core (native) and the melange-mode variant of the Transit
# library; the CLI's dune build only consumes `melange-transit-melange`.
buildDunePackage {
  pname = "melange-transit";
  version = "0.1.2";

  dunePackages = [
    "melange-transit-core"
    "melange-transit-melange"
  ];
  minimalOCamlVersion = "5.1";
  duneVersion = "3";

  src = fetchFromGitHub {
    owner = "logseq";
    repo = "melange-transit";
    rev = "38ca92e299cf34c897d9a44091fe86e55b1315ee";
    hash = "sha256-zF5cku6WcBA/tfh0oJ1469ekyI3ObrBsGY/4b0WLXNI=";
  };

  nativeBuildInputs = [
    melange
  ];
  propagatedBuildInputs = [
    melange
    melange-edn
  ];

  meta = {
    description = "Transit format serialization for OCaml and Melange";
    homepage = "https://github.com/logseq/melange-transit";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
