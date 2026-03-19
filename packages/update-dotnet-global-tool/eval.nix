{ pkg }:
# let
#   flake = builtins.getFlake path;
# in
{
  info = {
    inherit (pkg) pname version;
    nugetPackage = (pkg.nupkg or pkg).pname;
    nugetVersion = (pkg.nupkg or pkg).version;
  };
}
