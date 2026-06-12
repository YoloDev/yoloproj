{
  lib,
  buildDotnetGlobalTool,
  dotnetCorePackages,
  ...
}:

buildDotnetGlobalTool {
  pname = "glider";
  version = "6.15.0";

  nugetHash = "sha256-PqONBF6zR4c1I1YvI/aEoqim6ZeHsmtI4svy/aQzQ7c=";

  dotnet-sdk = dotnetCorePackages.dotnet_10.sdk;
  dotnet-runtime = dotnetCorePackages.dotnet_10.runtime;

  meta = {
    homepage = "https://glidermcp.com/";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    mainProgram = "glider";
  };
}
