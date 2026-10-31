{
  lib,
  buildDunePackage,
  fetchFromGitHub,
  melange,
}:

buildDunePackage {
  pname = "humanize";
  version = "0.1.0-unstable-2026-10-26";

  minimalOCamlVersion = "5.0";
  duneVersion = "3";

  src = fetchFromGitHub {
    owner = "rcmerci";
    repo = "humanize";
    rev = "747879af704dff4dd1897bc0f9a53a361071371c";
    hash = "sha256-NalrZxGlcMAIAjX6x7fFLJFZKEcr8E3R83iM87TfyyE=";
  };

  nativeBuildInputs = [ melange ];
  propagatedBuildInputs = [ melange ];

  doCheck = false;

  meta = {
    description = "Human-readable strings for numbers, lists, filesizes, and time spans";
    homepage = "https://github.com/rcmerci/humanize";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
