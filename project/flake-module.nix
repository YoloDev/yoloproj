{ flakeModules }:
{ lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

in
{
  imports = [
    flakeModules.pkgs
    flakeModules.dev
    flakeModules.hooks
    ./modules/formatting.nix
  ];

  perSystem =
    { config, ... }:
    let
      cfg = config.project;
    in
    {

      options.project = {
        enable = mkEnableOption "Enable the project module" // {
          default = true;
        };
      };

      # config = mkIf cfg.enable {
      # };
    };
}
