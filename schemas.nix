{ schemasLib, schemas }:
schemas
// {
  flakeModule = {
    version = 1;
    doc = ''
      **DEPRECATED**. Use `flakeModules.default` instead.
    '';
    inventory = output: {
      what = "Flake module";
    };
  };

  flakeModules = {
    version = 1;
    doc = ''
      The `flakeModules` flake output defines [Flake modules](https://flake.parts/).
    '';
    inventory =
      output:
      schemasLib.mkChildren (
        builtins.mapAttrs (configName: module: {
          what = "Flake module";
        }) output
      );
  };
}
