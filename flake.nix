{
  description = "Project defaults from YoloDev";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    flake-schemas.url = "github:DeterminateSystems/flake-schemas";

    oci = {
      url = "path:./oci";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pkgs = {
      url = "path:./pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dev = {
      url = "path:./dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hooks = {
      url = "path:./hooks";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    project = {
      url = "path:./project";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust = {
      url = "path:./rust";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      debug = false;
    in
    flake-parts.lib.mkFlake { inherit inputs; } (
      { inputs, config, ... }:
      let
        importApply = modulePath: staticArgs: flakeModules: {
          _file = modulePath;
          key = modulePath;
          imports = [ (import modulePath (staticArgs // { inherit flakeModules; })) ];
        };

        flakeModules = {
          dev = inputs.dev.mkFlakeModule importApply flakeModules;
          oci = inputs.oci.mkFlakeModule importApply flakeModules;
          pkgs = inputs.pkgs.mkFlakeModule importApply flakeModules;
          hooks = inputs.hooks.mkFlakeModule importApply flakeModules;
          project = inputs.project.mkFlakeModule importApply flakeModules;
          rust = inputs.rust.mkFlakeModule importApply flakeModules;
        };

        defaultsModule =
          { lib, ... }:
          {
            imports = [
              flakeModules.pkgs
              flakeModules.dev
              flakeModules.hooks
              flakeModules.project
            ];

            systems = lib.mkDefault [
              "x86_64-linux"
              "aarch64-linux"
            ];

            flake.schemas = lib.mkDefault inputs.flake-schemas.schemas;

            perSystem =
              { pkgs, ... }:
              {
                formatter = lib.mkDefault pkgs.nixfmt;
              };
          };
      in
      {
        inherit debug;

        imports = [
          defaultsModule
          inputs.flake-parts.flakeModules.flakeModules
        ];

        flake.flakeModule = defaultsModule;
        flake.flakeModules = {
          # not part of defaults
          inherit (flakeModules) oci rust;
          inherit (inputs.flake-parts.flakeModules) flakeModules;
        };

        flake.lib = {
          mkFlake =
            inputs: module:
            flake-parts.lib.mkFlake { inherit inputs; } {
              imports = [
                defaultsModule
                module
              ];
            };
        };
      }
    );
}
