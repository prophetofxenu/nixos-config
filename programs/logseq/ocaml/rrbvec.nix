{
  lib,
  buildDunePackage,
  fetchFromGitHub,
  melange,
}:

buildDunePackage {
  pname = "rrbvec";
  version = "0.1.0-unstable-2026-10-26";

  minimalOCamlVersion = "5.1";
  duneVersion = "3";

  src = fetchFromGitHub {
    owner = "logseq";
    repo = "rrbvec";
    rev = "dd5ce904f91d53235b5136f7a771f3f074c3971d";
    hash = "sha256-zYT7cMMWJivVSB6H/vUDnaajvUOYddh0MF2Zu/wIGq0=";
  };

  nativeBuildInputs = [ melange ];
  propagatedBuildInputs = [ melange ];

  # doCheck would pull in batteries/bechamel/qcheck; the CLI build only needs
  # the library itself.
  doCheck = false;

  meta = {
    description = "Persistent RRB vector implementation for native and Melange";
    homepage = "https://github.com/logseq/rrbvec";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
