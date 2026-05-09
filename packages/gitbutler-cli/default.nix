{
  lib,
  rustPlatform,
  cmake,
  pkg-config,
  fetchFromGitHub,
  libgit2,
  openssl,
  git,
  glib,
  dbus,
  nix-update-script,
  ...
}:

let
  cargoFlags = [
    "-p"
    "but"
  ];

in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gitbutler-cli";
  version = "0.19.10";

  src = fetchFromGitHub {
    owner = "gitbutlerapp";
    repo = "gitbutler";
    tag = "release/${finalAttrs.version}";
    hash = "sha256-s4ZLwWWkfreNX6pDIz3LoSBTCLV5hOyHujw4DVpI08k=";
  };

  cargoHash = "sha256-SRo8Eiv6fZVF5Y8vghNUBdnPvKK/IkirJRqvj26iTko=";

  nativeBuildInputs = [
    cmake # Required by `zlib-sys` crate
    pkg-config
  ];

  buildInputs = [
    libgit2
    openssl
    glib
    dbus
  ];

  nativeCheckInputs = [ git ];

  dontCargoCheck = true; # Who cares about tests?
  cargoBuildFlags = cargoFlags;

  env = {
    OPENSSL_NO_VENDOR = true;
    LIBGIT2_NO_VENDOR = 1;
  };

  passthru = {
    update = nix-update-script {
      extraArgs = [
        "--version-regex"
        "release/(.*)"
      ];
    };
  };

  meta = {
    homepage = "https://gitbutler.com";
    license = lib.licenses.fsl11Mit;
    platforms = lib.platforms.linux;
    mainProgram = "but";
  };
})
