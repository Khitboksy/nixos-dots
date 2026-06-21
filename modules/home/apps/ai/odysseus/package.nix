{
  pkgs,
  lib,
  odysseus-src,
  python3 ? pkgs.python3,
}:

let
  inherit (builtins)
    readFile
    match
    replaceStrings
    hasAttr
    filter
    map
    head
    ;
  inherit (lib.strings) splitString toLower;

  # ----- 1. Parse requirements.txt at evaluation time -----
  reqFile = readFile "${odysseus-src}/requirements.txt";

  parseLine =
    line:
    let
      trimmed = replaceStrings [ " " "\t" ] [ "" "" ] line;
      skip =
        trimmed == ""
        || match "#.*" trimmed != null
        || match "git\\+.*" trimmed != null
        || match "-r .*" trimmed != null
        || match "https?://.*" trimmed != null
        || match "--.*" trimmed != null;
      m = match "([a-zA-Z0-9_.-]+).*" trimmed;
    in
    if skip then
      null
    else if m != null then
      head m
    else
      null;

  pkgNames = lib.unique (filter (l: l != null) (map parseLine (splitString "\n" reqFile)));

  # ----- 2. Resolve each package: nixpkgs first, pip fallback -----
  resolveNixpkgs =
    pname:
    let
      candidates = [
        pname
        (replaceStrings [ "-" ] [ "_" ] pname)
        (toLower pname)
        (replaceStrings [ "-" ] [ "_" ] (toLower pname))
      ];
      try =
        cs:
        if cs == [ ] then
          null
        else if hasAttr (builtins.head cs) python3.pkgs then
          python3.pkgs.${builtins.head cs}
        else
          try (builtins.tail cs);
    in
    try candidates;

  resolved = map (p: {
    inherit p;
    result =
      if resolveNixpkgs p != null then
        {
          type = "nixpkgs";
          value = resolveNixpkgs p;
        }
      else
        {
          type = "pip";
          value = null;
        };
  }) pkgNames;

  nixpkgsDeps = filter (r: r.result.type == "nixpkgs") resolved;
  pipDeps = filter (r: r.result.type == "pip") resolved;
  pipOnlyNames = map (r: r.p) pipDeps;

  # ----- 3. Build the Python environment with nixpkgs deps -----
  pythonEnv = python3.withPackages (_: map (r: r.result.value) nixpkgsDeps);

in
pkgs.stdenv.mkDerivation {
  name = "odysseus";

  src = odysseus-src;

  # Opt out of the build sandbox so pip can fetch non-nixpkgs deps from PyPI.
  # This derivation needs network access during the build phase.
  # All other derivations remain fully sandboxed.
  __noChroot = true;

  nativeBuildInputs = [
    pythonEnv
    python3.pkgs.pip
    python3.pkgs.wheel
    pkgs.unzip
  ];

  buildPhase = ''
    runHook preBuild

    ${lib.optionalString (pipDeps != [ ]) ''
      echo "Odysseus: pip-installing ${builtins.toString (builtins.length pipDeps)} packages not in nixpkgs..."
      export HOME="$TMPDIR/home"
      export PIP_CACHE_DIR="$TMPDIR/pip-cache"
      mkdir -p "$PIP_CACHE_DIR" "$HOME" "$out/lib/python-pip-deps"

      # --no-deps: transitive deps are handled by nixpkgs where possible.
      # If a pip-only package needs a dep that's also pip-only, pip handles
      # it naturally since the target dir is on PYTHONPATH at runtime.
      ${python3.pkgs.pip}/bin/pip install \
        --no-input \
        --no-deps \
        --no-warn-script-location \
        --target="$out/lib/python-pip-deps" \
        ${lib.concatStringsSep " " (map (d: "'${d}'") pipOnlyNames)}

      echo "Odysseus: pip install complete."
    ''}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Copy all source files into the output
    mkdir -p "$out/share/odysseus"
    cp -r . "$out/share/odysseus/"
    rm -rf "$out/share/odysseus/.git" 2>/dev/null || true

    # Create launcher wrapper
    #
    # Odysseus hardcodes paths relative to source files using
    #   Path(__file__).resolve().parent.parent / "data"
    # Since the source lives in the nix store (read-only), we build a
    # writable "symlink farm" in $XDG_DATA_HOME/odysseus/app/:
    #   - Real directories for everything (so subdirs can be created)
    #   - All .py files are real copies → Path(__file__).resolve()
    #     stays in the writable app directory
    #   - Everything else (configs, static assets, docs) is symlinked
    #     to the nix store (no duplication)
    # This definitively avoids Path(__file__).resolve() following
    # symlinks into the read-only nix store.
    mkdir -p "$out/bin"
    cat > "$out/bin/odysseus" << EOF
    #!${pkgs.runtimeShell}
    set -e

    # ---- Python environment ----
    # nixpkgs-packaged deps (reproducible, cached)
    export PYTHONPATH="${pythonEnv}/${python3.sitePackages}"
    # pip-installed deps (for packages not in nixpkgs)
    if [ -d "$out/lib/python-pip-deps" ]; then
      export PYTHONPATH="$out/lib/python-pip-deps":\$PYTHONPATH
    fi

    # ---- Writable app directory (symlink farm) ----
    DATA_DIR="\''${XDG_DATA_HOME:-\$HOME/.local/share}/odysseus"
    APP_DIR="\$DATA_DIR/app"

    # Clean entire old app tree (some files may be read-only due to nix-store
    # permissions from prior real copies), then recreate.
    chmod -R u+w "\$APP_DIR" 2>/dev/null || true
    rm -rf "\$APP_DIR" 2>/dev/null || true
    mkdir -p "\$APP_DIR"

    cd "$out/share/odysseus"

    # ---- Symlink farm: real dirs + hybrid copy/symlink ----
    # Real directories for everything. Python's Path(__file__).resolve()
    # follows symlinks, so .py symlinks would resolve into the read-only
    # store. Solution: copy .py files as real copies, symlink everything
    # else.  This is a one-time cost of ~6 MB per rebuild.
    #
    # The static/ tree must also be real copies (not symlinks) because
    # Starlette's StaticFiles (v0.52+) defaults follow_symlink=False,
    # resolving realpaths and rejecting files outside the static dir.
    find . -type d -not -path "./static/*" -printf "%P\0" |
      xargs -0 -I{} mkdir -p "\$APP_DIR/{}"

    # .py files: real copies (so __file__ stays writable)
    find . -type f -name '*.py' -printf "%P\0" |
      xargs -0 -I{} cp "$out/share/odysseus/{}" "\$APP_DIR/{}"

    # static/ tree: real copies (Starlette follow_symlink=False)
    mkdir -p "\$APP_DIR/static"
    cp -r "$out/share/odysseus/static/." "\$APP_DIR/static/"

    # Everything else: symlinks to the nix store
    find . -type f -not -name '*.py' -not -path "./static/*" -printf "%P\0" |
      xargs -0 -I{} ln -sf "$out/share/odysseus/{}" "\$APP_DIR/{}"

    # ---- First-run setup (creates data/, logs/, DB, admin user) ----
    cd "\$APP_DIR"
    ${pythonEnv}/bin/python setup.py 2>/dev/null || true

    # ---- Launch the server ----
    exec ${pythonEnv}/bin/python -m uvicorn app:app \
      --host "\''${ODYSSEUS_HOST:-127.0.0.1}" \
      --port "\''${ODYSSEUS_PORT:-7000}"
    EOF
    chmod +x "$out/bin/odysseus"

    runHook postInstall
  '';

  meta = with lib; {
    description = "PewDiePie's Odysseus AI Workspace — self-hosted AI workspace";
    homepage = "https://github.com/pewdiepie-archdaemon/odysseus";
    license = licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
