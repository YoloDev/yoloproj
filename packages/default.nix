{ pkgs, inputs', ... }:
{
  packages = rec {
    update-dotnet-global-tool = pkgs.callPackage ./update-dotnet-global-tool { };
    glider = pkgs.callPackage ./glider { };
  };
}
