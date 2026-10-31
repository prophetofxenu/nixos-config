{
  lib,
  buildDunePackage,
  fetchFromGitHub,
  melange,
}:

# Builds both the core (native) and the melange-mode variant of the EDN
# library; the CLI's dune build only consumes `melange-edn-melange`.
buildDunePackage {
  pname = "melange-edn";
  version = "0.5.0";

  dunePackages = [
    "melange-edn-core"
    "melange-edn-melange"
  ];
  minimalOCamlVersion = "5.1";
  duneVersion = "3";

  src = fetchFromGitHub {
    owner = "logseq";
    repo = "melange-edn";
    rev = "3cb79f278e972388a0a2b2ea1caec7a008a0b956";
    hash = "sha256-mdkjo4csQrQw0uTYaQ2gjlGp2kHSjN3PL4ljFDDTwQ8=";
  };

  nativeBuildInputs = [ melange ];
  propagatedBuildInputs = [ melange ];

  meta = {
    description = "EDN reader/writer for OCaml and Melange";
    homepage = "https://github.com/logseq/melange-edn";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
