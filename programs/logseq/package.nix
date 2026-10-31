# Logseq 2.0.2 (DB version) — standalone Nix derivation.
#
# This is NOT the file-based Logseq 0.10.x in nixpkgs. 2.0.2 is built with:
#   - pnpm (3 lockfiles: root, static/ [from resources/], cli/)
#   - shadow-cljs (ClojureScript) for the app, db workers and electron main
#   - vite (db-worker-node bundle) + webpack (db-worker for the renderer)
#   - dune/melange (OCaml) for the bundled CLI (`logseq-cli.js`)
#
# electron-builder is deliberately not used: its only job upstream is to turn
# the finished `static/` directory into an AppImage/asar. We install the pruned
# `static/` dir as an unpacked Electron app at
#   $out/share/logseq/resources/app
# and wrap nixpkgs' electron. Runtime code paths that depend on packaging
# state were verified safe for this layout:
#   - `dev?` comes from NODE_ENV, which shadow-cljs hard-codes to "production"
#     in release builds (compile-time, not runtime)
#   - `cli-script-path`: isPackaged=false -> `__dirname/logseq-cli.js`, staged
#     by scripts/prepare-desktop-runtime-js.mjs into static/
#   - `sidecar-dir`: isPackaged=false -> `__dirname/../sidecar`, which resolves
#     to $out/share/logseq/resources/sidecar (same place upstream puts it)
#   - db workers are spawned with `process.execPath` + ELECTRON_RUN_AS_NODE=1
#   - the auto-updater channel is nil on Linux
{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  fetchPnpmDeps,
  replaceVars,
  writeShellScriptBin,
  copyDesktopItems,
  cacert,
  clojure,
  makeDesktopItem,
  makeWrapper,
  nodejs_24,
  python3,
  pkg-config,
  removeReferencesTo,
  glib,
  libsecret,
  electron_42,
  git,
  ocaml-ng,
  pnpm_10,
  pnpmConfigHook,
}:

let
  electron = electron_42;
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "logseq";
    repo = "logseq";
    tag = version;
    hash = "sha256-rsVjF5LywZoQda9w6mobfnOdbZWo56inz/27jNzUTmo=";
  };

  #
  # OCaml / Melange toolchain for the bundled CLI (cli/ -> logseq-cli.js).
  #
  # Upstream CI pins OCaml 5.1.1 and lets opam resolve the git-pinned libs at
  # their branch heads; we use nixpkgs' ocamlPackages_5_3 (melange 7.0.1-53)
  # and pin the exact commits the opam pin-depends resolve to today.
  #
  ocamlPackages = ocaml-ng.ocamlPackages_5_3.overrideScope (
    self: prev: {
      melange-fetch = self.callPackage ./ocaml/melange-fetch.nix { };
      melange-fest = self.callPackage ./ocaml/melange-fest.nix { };
      melange-edn = self.callPackage ./ocaml/melange-edn.nix { };
      melange-transit = self.callPackage ./ocaml/melange-transit.nix { };
      rrbvec = self.callPackage ./ocaml/rrbvec.nix { };
      humanize = self.callPackage ./ocaml/humanize.nix { };
    }
  );

  # findlib libraries the cli/ dune project depends on
  cliOcamlLibs = with ocamlPackages; [
    melange
    melange-fetch
    melange-fest
    melange-edn
    melange-transit
    rrbvec
    humanize
  ];

  # Clojure git deps -> store paths (substituted into hardcode-git-paths.patch)
  #
  gitDep =
    owner: repo: rev: hash:
    fetchFromGitHub {
      inherit owner repo rev hash;
    };

  glogiSrc = gitDep "lambdaisland" "glogi" "30328a045141717aadbbb693465aed55f0904976" "sha256-80hwqNABpeURdICwArbkdsBPTkDnGqXbqfk9JvyeTsU=";
  malliSrc = gitDep "metosin" "malli" "52ea58a36ff5172b38dfc526ca638afa7226a4a0" "sha256-gIICk3ZXTYxsBOOl+49M9+a98z9rl0JXj1/2LEGiD74=";
  cljFractionalIndexingSrc = gitDep "logseq" "clj-fractional-indexing" "1087f0fb18aa8e25ee3bbbb0db983b7a29bce270" "sha256-H1pdNX+YbIpwd49L7/ku6YeXp0Jv6BmHZRQdRqopQwc=";
  logseqSchemaSrc = gitDep "logseq" "logseq-schema" "6eeb51cd6d80bbffa0873c1e79790dc1f4ff68cf" "sha256-ZFinS8+GGDx+JulwW1PGgN5Jo2wFc1P55IoMHMKrLG4=";

  # logseq-schema's own deps.edn declares glogi, clj-fractional-indexing and
  # malli with git/mvn coordinates. The root deps.edn pins the same projects
  # as :local/root, and clojure refuses to pick between the two providers
  # ("Unable to compare versions"). Rewrite logseq-schema's deps.edn to point
  # at the identical store paths.
  logseqSchemaPatched = stdenv.mkDerivation {
    name = "logseq-schema-6eeb51c-patched";
    # TODO what does this do?
    dontUnpack = true;

    buildPhase = ''
      cp -r ${logseqSchemaSrc} $out
      chmod -R u+w $out
      cat > $out/deps.edn <<EOF
  {:paths ["src"]
   :deps
   {metosin/malli {:local/root "${malliSrc}"}
    com.lambdaisland/glogi {:local/root "${glogiSrc}"}
    logseq/clj-fractional-indexing {:local/root "${cljFractionalIndexingSrc}"}}}
  EOF
    '';

    # TODO what does this do?
    installPhase = ":";
  };

  clojureDepsPatch = replaceVars ./hardcode-git-paths.patch {
    hsx_src = gitDep "logseq" "hsx" "21615ffa2aa530cc830e3464b793a53ef4fdd18c" "sha256-uzlqVCilfpyHgbKd1M+mP6u3+0eTUBKbeclCCQWQMYg=";
    rfx_src = gitDep "logseq" "rfx" "d37aaceb37fcaf969c5cd04646dfdb985d65d3c2" "sha256-ZWxELDRFqdUC9JOVR1qkq9sZLlg/kAOYSxsSI9E9Xz0=";
    datascript_src = gitDep "logseq" "datascript" "3f141af97b70e1f14c65eaa119acd822ebece37e" "sha256-hFO/uUzO9hISSD5tEGkHhN56+GD6RtOUZGCNwWXlVCQ=";
    cljs_time_src = gitDep "logseq" "cljs-time" "5704fbf48d3478eedcf24d458c8964b3c2fd59a9" "sha256-IApL+SEm7AhbTN7J/1KiAKTx7rd53hchRh3jmPQ412g=";
    glogi_src = glogiSrc;
    malli_src = malliSrc;
    cljc_fsrs_src = gitDep "open-spaced-repetition" "cljc-fsrs" "eeef3520df664e51c3d0ba2031ec2ba071635442" "sha256-C/SvcUTC9BS61T3XWJjolZFrYHwhu5vdrGtAsz1qePA=";
    logseq_schema_src = logseqSchemaPatched;
    clj_fractional_indexing_src = cljFractionalIndexingSrc;
  };

  #
  # Maven repo + gitlibs for the shadow-cljs build. `clj -P` resolves every
  # Maven repo for the shadow-cljs build. `clj -P` resolves every dependency
  # of `deps.edn` (+ the :cljs alias) into $out/m2. All git deps (direct and
  # transitive via logseq-schema) were rewritten to :local/root store paths,
  # so the resolution is fully offline after this FOD.
  #
  mavenRepo = stdenv.mkDerivation {
    name = "logseq-${version}-maven-deps";
    inherit src;
    patches = [ clojureDepsPatch ];

    nativeBuildInputs = [ clojure cacert ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      export HOME="$(mktemp -d)"
      mkdir -p "$out/m2"

      # -P       -> resolve all normal deps
      # -M:alias -> also resolve the extra-deps of the listed aliases
      clj -Sdeps "{:mvn/local-repo \"$out/m2\"}" -P -M:cljs

      runHook postBuild
    '';

    # copied from buildMavenPackage: remove ephemeral files
    installPhase = ''
      runHook preInstall

      find "$out/m2" -type f \( \
        -name \*.lastUpdated \
        -o -name resolver-status.properties \
        -o -name _remote.repositories \) \
        -delete

      runHook postInstall
    '';

    # TODO what does this do?
    dontFixup = true;

    outputHash = "sha256-5viToQJy8o4oRN2xYJHDs0+EBB7AXzKb7UqlelZfrFM=";
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
  };

  pnpmDepsRoot = fetchPnpmDeps {
    pname = "logseq";
    inherit version src;
    hash = "sha256-xdEEk5N/G0wGHBYvFLe8N2EL66DYUpVpCSHkvvbsIuE=";
    pnpm = pnpm_10;
    fetcherVersion = 3;
  };

  # static/ is generated by gulp from resources/ (same package.json + lockfile)
  pnpmDepsStatic = fetchPnpmDeps {
    pname = "logseq-static";
    inherit version src;
    sourceRoot = "${src.name}/resources";
    # TODO what does this do?
    pnpmInstallFlags = [ "--ignore-workspace" ];
    hash = "sha256-YDqkZIzs9yAtKJfmbRIoR5G7GQQYve5yRrAa1qYiboc=";
    pnpm = pnpm_10;
    fetcherVersion = 3;
  };

  pnpmDepsCli = fetchPnpmDeps {
    pname = "logseq-cli";
    inherit version src;
    sourceRoot = "${src.name}/cli";
    pnpmInstallFlags = [ "--ignore-workspace" ];
    hash = "sha256-EWSyhc/6oJGMqz1vcfspJiOuQSzqTRS3Oyy/Fpg7Jrk=";
    pnpm = pnpm_10;
    fetcherVersion = 3;
  };

  clojureWithCache = writeShellScriptBin "clojure" ''
    exec ${lib.getExe' clojure "clojure"} -Sdeps '{:mvn/local-repo "${mavenRepo}/m2"}' "$@"
  '';

  # TODO probably remove this?
  # the shadow-cljs build-metadata-hook and the CLI's vite config both run
  # `git describe --long --always --dirty`; LOGSEQ_REVISION short-circuits
  # both, but keep a fake git around just in case something shells out.
  fakeGit = writeShellScriptBin "git" ''
    echo "${version}@nixpkgs"
  '';

  desktopItem = makeDesktopItem {
    name = "Logseq";
    desktopName = "Logseq";
    exec = "logseq %U";
    terminal = false;
    icon = "logseq";
    startupWMClass = "Logseq";
    comment = "A privacy-first, open-source platform for knowledge management and collaboration.";
    mimeTypes = [ "x-scheme-handler/logseq" ];
    categories = [ "Utility" ];
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "logseq";
  inherit version src;

  patches = [ clojureDepsPatch ];

  strictDeps = true;

  nativeBuildInputs = [
    clojureWithCache
    fakeGit
    copyDesktopItems
    makeWrapper
    nodejs_24
    pnpm_10
    pnpmConfigHook
    python3 # node-gyp (keytar)
    pkg-config
    removeReferencesTo

    # OCaml CLI build
    ocamlPackages.ocaml
    ocamlPackages.dune_3
    ocamlPackages.findlib
    ocamlPackages.melange
  ];

  buildInputs =
    [
      # keytar native module deps
      glib
      libsecret
    ]
    ++ cliOcamlLibs;

  # we unpack all three pnpm stores manually in buildPhase
  # (root / static / cli), so configurePhase must not install anything.
  dontPnpmConfigure = true;
  # pnpmConfigHook checks this attribute even when disabled
  pnpmDeps = pnpmDepsRoot;

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    # the project pins packageManager=pnpm@10.33.0; don't let pnpm try to
    # self-install that version from the registry
    npm_config_manage_package_manager_versions = "false";
  };

  buildPhase = ''
    runHook preBuild

    # Unpack a fetchPnpmDeps store and configure pnpm to use it (replicates
    # pnpmConfigHook's setup for the multi-directory installs below).
    setupPnpmStore() {
      local storeDir
      storeDir="$(mktemp -d)"
      tar --zstd -xf "$1/pnpm-store.tar.zst" -C "$storeDir"
      chmod -R +w "$storeDir"
      if [ -f "$storeDir/v11/index.db.sql" ]; then
        sqlite3 "$storeDir/v11/index.db" < "$storeDir/v11/index.db.sql"
        rm "$storeDir/v11/index.db.sql"
      fi
      pnpm config set store-dir "$storeDir"
      pnpm config set package-import-method clone-or-copy
      pnpm config set side-effects-cache false
      pnpm config set manage-package-manager-versions false
    }

    # Hermetic build metadata: the shadow-cljs build-metadata-hook (app +
    # db-worker) and the CLI's vite config all embed the same revision, and
    # the db-worker lifecycle refuses workers whose revision differs.
    export LOGSEQ_REVISION="${version}@nixpkgs"
    export LOGSEQ_BUILD_TIME="$(date -u -d "@''${SOURCE_DATE_EPOCH:-0}" '+%Y-%m-%dT%H:%M:%SZ')"

    # 1. root node_modules (build tooling: gulp, shadow-cljs, webpack...)
    setupPnpmStore "${pnpmDepsRoot}"
    pnpm install --offline --ignore-scripts --frozen-lockfile

    # 2. static/: assets, CSS, resources copy (creates the app dir)
    pnpm run gulp:build

    # 3. static node_modules (runtime deps of the electron main process)
    # TODO what does this do?
    pushd static
    setupPnpmStore "${pnpmDepsStatic}"
    pnpm install --offline --ignore-scripts --ignore-workspace --frozen-lockfile
    popd

    # 4. cli node_modules (vite for the melange bundle)
    pushd cli
    setupPnpmStore "${pnpmDepsCli}"
    pnpm install --offline --ignore-scripts --ignore-workspace --frozen-lockfile
    popd
    patchShebangs static/node_modules cli/node_modules

    # 5. ClojureScript: app, db workers, electron main, publishing
    pnpm run cljs:release-electron

    # 6. db-worker-node standalone bundle (vite)
    pnpm run db-worker-node:bundle

    # 7. OCaml/Melange CLI + stage it into static/
    pushd cli
    dune build @bundle
    popd
    node scripts/stage-cli-runtime.mjs

    # 8. webpack: db-worker bundle for the renderer
    pnpm run webpack-app-build

    # 9. copy CLI/db-worker runtime JS + SKILL.md into static/
    pnpm run desktop:prepare-runtime-js

    # 10. prune what electron-builder's `files` config excludes
    rm -rf static/mobile static/android static/ios
    echo "${version}" > static/VERSION

    # 11. rebuild keytar's native module against electron's ABI.
    # (`pnpm rebuild` is a silent no-op for --ignore-scripts installs here.)
    # @zvec/zvec needs no rebuild: the runtime uses the prebuilt
    # @zvec/bindings-linux-x64 .node binary.
    export npm_config_nodedir=${electron.headers}
    pushd static
    node node_modules/.pnpm/node-gyp@12.4.0/node_modules/node-gyp/bin/node-gyp.js \
      rebuild --directory=node_modules/.pnpm/keytar@7.9.0/node_modules/keytar
    # remove traces of electron.headers / the build tree
    find node_modules \( -name '*.target.mk' -o -name config.gypi -o -name Makefile \) -delete
    find node_modules -type d -path '*build/Release/.deps' -exec rm -rf {} +
    find node_modules -type d -path '*build/obj.target' -exec rm -rf {} +
    popd
    unset npm_config_nodedir

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/logseq/resources
    cp -r static $out/share/logseq/resources/app
    cp -r sidecar $out/share/logseq/resources/sidecar

    install -Dm644 static/icons/logseq.png \
      $out/share/icons/hicolor/512x512/apps/logseq.png

    # strip build-time references to nodejs from runtime executables
    # TODO why?
    find $out/share/logseq/resources/app/node_modules -type f -executable \
      -exec remove-references-to -t ${nodejs_24} '{}' \; || true

    makeWrapper ${lib.getExe electron} $out/bin/logseq \
      --add-flags $out/share/logseq/resources/app \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
        # keytar.node links these; the unpacked app has no bundling
        glib
        libsecret
      ]} \
      --inherit-argv0

    runHook postInstall
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    export HOME="$(mktemp -d)"
    export ELECTRON_RUN_AS_NODE=1

    echo "== logseq-cli --help =="
    ${lib.getExe electron} $out/share/logseq/resources/app/logseq-cli.js --help | tee cli-help.txt
    grep -qE "USAGE|Usage|COMMANDS|Commands" cli-help.txt

    echo "== db-worker-node --help =="
    ${lib.getExe electron} $out/share/logseq/resources/app/js/db-worker-node.js --help

    test -f $out/share/logseq/resources/sidecar/embedding_server.py
    test -f $out/share/logseq/resources/app/.agents/skills/logseq-cli/SKILL.md

    runHook postInstallCheck
  '';

  # TODO what does this do?
  passthru = {
    inherit
      electron
      mavenRepo
      pnpmDepsRoot
      pnpmDepsStatic
      pnpmDepsCli
      ocamlPackages
      ;
  };

  desktopItems = [ desktopItem ];

  meta = {
    description = "Privacy-first, open-source platform for knowledge management and collaboration (DB version)";
    homepage = "https://github.com/logseq/logseq";
    license = lib.licenses.agpl3Only;
    mainProgram = "logseq";
    platforms = [ "x86_64-linux" ];
  };
})
