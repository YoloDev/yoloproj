{ ... }:
{ inputs, lib, ... }:
assert (inputs ? nixpkgs);
let
  inherit (lib) mkOption types;

  overlayType = types.functionTo types.raw;

in
{
  perSystem =
    { config, system, ... }:
    let
      cfg = config.pkgs;
    in
    {
      options = {
        pkgs.overlays = mkOption {
          type = types.listOf overlayType;
          default = [ ];
          description = "List of overlays to apply to the system pkgs.";
        };

        pkgs.config.allowUnfree = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to allow unfree packages in the system pkgs.";
        };
      };

      config = {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          inherit (cfg) overlays config;
        };
      };
    };
}
