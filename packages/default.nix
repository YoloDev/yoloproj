{
  pkgs,
  lib,
  config,
  ...
}:
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

  unfilteredPackages = {
    dotnet-verify = pkgs.callPackage ./dotnet-verify { inherit buildDotnetGlobalTool; };
    glider = pkgs.callPackage ./glider { inherit buildDotnetGlobalTool; };
    nuget-mcp-server = pkgs.callPackage ./nuget-mcp { inherit buildDotnetGlobalTool; };
    t3code = pkgs.callPackage ./t3code { };
    op-direnv = pkgs.callPackage ./op-direnv { };
  };

  packages = lib.filterAttrs (
    name: pkg:
    let
      system = pkgs.stdenv.hostPlatform.system;
      platforms = pkg.meta.platforms or lib.platforms.all;
    in
    builtins.elem system platforms
  ) unfilteredPackages;

  checks = lib.mapAttrs' (name: value: {
    inherit value;
    name = "pkg-${name}";
  }) packages;
in
{
  inherit
    packages
    checks
    ;

  apps = {
    update-packages = {
      type = "app";
      program = pkgs.lib.getExe update-packages;
    };
  };
}
