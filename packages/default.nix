{ pkgs, inputs', ... }:
{
  packages = {
    glider = pkgs.callPackage ./glider { };
  };
}
