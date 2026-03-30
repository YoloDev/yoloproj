{
  lib,
  gcc,
  pkgs,
  stdenv,
  nodejs,
  pnpm_10,
  python3,
  gnumake,
  pkg-config,
  makeWrapper,
  nodePackages,
  fetchPnpmDeps,
  pnpmConfigHook,
  fetchFromGitHub,
}:

stdenv.mkDerivation (
  finalAttrs:
  let
    pnpm = pnpm_10;

    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./package.json
        ./pnpm-lock.yaml
      ];
    };

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 3;
      hash = finalAttrs.depsHash;
    };

  in
  {
    pname = "t3code";
    version = "0.0.15";

    depsHash = "sha256-nX1fRMJSEkaCtO1Ttn4eubZ3BRrLwfGkFlMfFQ18BJw=";

    buildInputs = [ stdenv.cc.cc ];

    nativeBuildInputs = [
      pnpm
      pnpmConfigHook
      makeWrapper
      nodejs
      python3
      pkg-config
      gnumake
      nodePackages.node-gyp
    ];

    env = {
      NIX_NODEJS_BUILDNPMPACKAGE = "1";
      npm_config_build_from_source = "true";
      npm_config_nodedir = "${nodejs}";
      PYTHON = "${python3}/bin/python3";
    };

    buildPhase = ''
      runHook preBuild

      # Useful while debugging:
      # node --version
      # pnpm --version
      # $CXX --version
      # $PYTHON --version

      # Build native addons from the already-installed offline deps:
      pnpm --reporter=append-only rebuild node-pty --verbose

      # Useful while debugging:
      # find . -name pty.node
      # exit 1

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out"/lib/node_modules/t3code
      mkdir -p "$out"/bin

      cp -a . "$out"/lib/node_modules/t3code/
      makeWrapper "$out"/lib/node_modules/t3code/node_modules/.bin/t3 $out/bin/t3 \
        --prefix PATH : ${lib.makeBinPath [ nodejs ]}

      runHook postInstall
    '';

    inherit pnpmDeps src;

    passthru = {
      update = pkgs.callPackage ./update.nix { };
    };

    meta = {
      description = "T3 Code is a minimal web GUI for coding agents";
      homepage = "https://github.com/pingdotgg/t3code";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
      mainProgram = "t3";
    };
  }
)
