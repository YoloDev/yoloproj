{ pkgs, config, ... }:
let
  update-dotnet-global-tool = pkgs.callPackage ./update-dotnet-global-tool { };
  update-packages = pkgs.callPackage ./update-packages { inherit (config) packages; };

  buildDotnetGlobalTool =
    args:
    pkgs.buildDotnetGlobalTool (
      args
      // {
        passthru = (args.passthru or { }) // {
          update = update-dotnet-global-tool;
        };
      }
    );
in
{
  packages = {
    glider = pkgs.callPackage ./glider { inherit buildDotnetGlobalTool; };
    t3code = pkgs.callPackage ./t3code { };
  };

  apps = {
    update-packages = {
      type = "app";
      program = pkgs.lib.getExe update-packages;
    };
  };
}
