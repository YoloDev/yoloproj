{ devshell, flakeModules }:
{ lib, ... }:
{
  imports = [
    devshell.flakeModule
    flakeModules.pkgs
  ];

  perSystem =
    { ... }:
    {
      devshells.default =
        { pkgs, ... }:
        {
          packages = [
            # Task runner
            pkgs.just

            # Cli utils
            pkgs.jq
            pkgs.yq-go
          ];
        };
    };
}
