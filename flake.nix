{
  description = "Project defaults from YoloDev";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

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
  };

  outputs =
    inputs@{ flake-parts, ... }:
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
        };

        defaultsModule =
          { lib, ... }:
          {
            imports = [
              flakeModules.pkgs
              flakeModules.dev
              flakeModules.hooks
              flakeModules.project
              inputs.flake-parts.flakeModules.flakeModules
            ];

            systems = lib.mkDefault [
              "x86_64-linux"
              "aarch64-linux"
            ];

            perSystem =
              { pkgs, ... }:
              {
                formatter = lib.mkDefault pkgs.nixfmt;
              };
          };
      in
      {
        debug = true;

        imports = [
          defaultsModule
        ];

        flake.flakeModule = defaultsModule;
        flake.flakeModules = {
          # not part of defaults
          inherit (flakeModules) oci;
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
