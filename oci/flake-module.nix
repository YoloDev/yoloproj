{ nix2container, flakeModules }:
{ lib, ... }:
{
  imports = [
    flakeModules.pkgs
  ];

  perSystem =
    { pkgs, config, ... }:
    let
      inherit (lib) mkOption types;
      inherit (pkgs.nix2container) buildImage buildLayer;
      cfg = config.oci;

    in
    {
      options.oci =
        let
          rootEnvType = types.submodule (
            { config, ... }:
            {
              options = {
                name = mkOption {
                  type = types.str;
                  default = "root";
                  description = "The name of the root environment";
                };

                paths = mkOption {
                  type = types.listOf types.package;
                  default = [ ];
                  description = "The paths to copy to the root environment";
                };

                pathsToLink = mkOption {
                  type = types.listOf types.str;
                  default = [ "/bin" ];
                  description = "The paths to link in the root environment";
                };

                _out = mkOption {
                  type = types.package;
                  readOnly = true;
                  internal = true;
                };
              };

              config._out = pkgs.buildEnv {
                inherit (config) name paths pathsToLink;
              };
            }
          );

          layerType = types.submodule (
            { config, ... }:
            {
              options = {
                maxLayers = mkOption {
                  type = types.ints.positive;
                  default = 1;
                  description = "The maximum number of layers to use";
                };

                copyToRoot = mkOption {
                  type = types.nullOr rootEnvType;
                  default = null;
                  description = "The root environment to copy to the root of the image";
                };

                deps = mkOption {
                  type = types.listOf types.package;
                  default = [ ];
                  description = "The dependencies to include in the image layer";
                };

                layers = mkOption {
                  type = types.listOf layerType;
                  default = [ ];
                  description = "The layers to use";
                };

                _dbg = mkOption {
                  type = types.raw;
                  readOnly = true;
                  internal = true;
                };

                _out = mkOption {
                  type = types.package;
                  readOnly = true;
                  internal = true;
                };
              };

              config =
                let
                  attrs = {
                    inherit (config) maxLayers deps;

                    layers = lib.map (layer: layer._out) config.layers;
                    copyToRoot = if config.copyToRoot != null then config.copyToRoot._out else null;
                  };

                  out = buildLayer attrs;
                in
                {
                  _dbg = attrs;
                  _out = out;
                };
            }
          );

          imageType = types.submodule (
            { name, config, ... }:
            {
              options = {
                name = mkOption {
                  type = types.str;
                  default = name;
                  description = "The image name";
                };

                maxLayers = mkOption {
                  type = types.ints.positive;
                  default = 1;
                  description = "The maximum number of layers to use";
                };

                copyToRoot = mkOption {
                  type = types.nullOr rootEnvType;
                  default = null;
                  description = "The root environment to copy to the root of the image";
                };

                layers = mkOption {
                  type = types.listOf layerType;
                  default = [ ];
                  description = "The layers to use";
                };

                config = {
                  entrypoint = mkOption {
                    type = types.uniq (types.nullOr (types.listOf types.str));
                    default = null;
                    description = "The entrypoint command";
                  };

                  cmd = mkOption {
                    type = types.uniq (types.nullOr (types.listOf types.str));
                    default = null;
                    description = "The cmd command";
                  };

                  env = mkOption {
                    type = types.lazyAttrsOf types.str;
                    default = { };
                    description = "The environment variables";
                  };
                };

                _dbg = mkOption {
                  type = types.raw;
                  readOnly = true;
                  internal = true;
                };

                _out = mkOption {
                  type = types.package;
                  readOnly = true;
                  internal = true;
                };
              };

              config =
                let
                  attrs = {
                    inherit (config) name maxLayers;
                    inherit (cfg) arch;

                    layers = lib.map (layer: layer._out) config.layers;
                    copyToRoot = if config.copyToRoot != null then config.copyToRoot._out else null;

                    config = lib.mergeAttrsList [
                      {
                        env = lib.mapAttrsToList (name: value: "${name}=${value}") config.config.env;
                      }

                      (lib.optionalAttrs (config.config.cmd != null) {
                        cmd = config.config.cmd;
                      })

                      (lib.optionalAttrs (config.config.entrypoint != null) {
                        entrypoint = config.config.entrypoint;
                      })
                    ];
                  };

                  out =
                    assert !pkgs.stdenv.isDarwin;
                    buildImage attrs;
                in
                {
                  _dbg = attrs;
                  _out = out;
                };
            }
          );

        in
        {
          arch = mkOption {
            type = types.str;
            default = pkgs.go.GOARCH;
            description = "The architecture to build for";
          };

          images = mkOption {
            type = types.lazyAttrsOf imageType;
            default = { };
            description = "Images to build";
          };
        };

      config = {
        pkgs.overlays = [
          (final: prev: {
            inherit (nix2container.packages.${final.stdenv.hostPlatform.system})
              nix2container
              skopeo-nix2container
              ;
          })
        ];

        packages =
          let
            mkImagePackage = image: {
              "oci-${image.name}-spec-json" = image._out;
              "oci-${image.name}-copy" = pkgs.writeShellApplication {
                name = "copy-${image.name}";

                runtimeInputs = [
                  pkgs.skopeo-nix2container
                ];

                text = ''
                  skopeo --insecure-policy copy --format oci "nix:${image._out}" "$1"
                '';
              };
            };

            images = lib.concatMapAttrs (name: image: mkImagePackage image) cfg.images;
          in
          images;
      };
    };
}
