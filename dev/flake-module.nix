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
          packages = [ pkgs.just ];
        };
    };
}
