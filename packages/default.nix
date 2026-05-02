{
  pkgs,
  lib,
  config,
  ...
}:
let
  defaults = {
  };

  callPackage =
    path: extras:
    pkgs.callPackage path (
      defaults
      // extras
      // {
        nix-update-script =
          args:
          let
            filePath =
              if builtins.pathExists (path + "/.") then (toString path) + "/default.nix" else (toString path);
            extraArgs = (args.extraArgs or [ ]) ++ [
              "--flake"
              "--override-filename"
              "packages/${lib.strings.removePrefix "${toString ./.}/" filePath}"
            ];
          in
          pkgs.nix-update-script (args // { inherit extraArgs; });
      }
    );

  update-dotnet-global-tool = callPackage ./update-dotnet-global-tool { };
  update-packages = callPackage ./update-packages { inherit (config) packages; };

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
    dotnet-verify = callPackage ./dotnet-verify { inherit buildDotnetGlobalTool; };
    glider = callPackage ./glider { inherit buildDotnetGlobalTool; };
    nuget-mcp-server = callPackage ./nuget-mcp-server { inherit buildDotnetGlobalTool; };
    t3code = callPackage ./t3code { };
    op-direnv = callPackage ./op-direnv { };
    gitbutler-cli = callPackage ./gitbutler-cli { };
  };

  packages' = lib.filterAttrs (
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
  }) packages';

  packages = packages' // {
    inherit update-packages;
  };
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
