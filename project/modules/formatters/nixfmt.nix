{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.project.formatting.formatters.nixfmt;

in
{
  project.formatting.formatters.nixfmt = {
    package = lib.mkDefault pkgs.nixfmt;
    commands.format = lib.mkDefault cfg.package;
    commands.check = lib.mkDefault "${lib.getExe cfg.package} --check";
    files.extensions.nix = true;
  };
}
