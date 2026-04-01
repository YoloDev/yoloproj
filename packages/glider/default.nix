{
  lib,
  buildDotnetGlobalTool,
  dotnetCorePackages,
}:

buildDotnetGlobalTool {
  pname = "glider";
  version = "6.3.0";

  nugetHash = "sha256-ESd7ewITRK+XoHDbB0/ykBfBa3HzlTtkK/NpSVrgUy0=";

  dotnet-sdk = dotnetCorePackages.dotnet_10.sdk;
  dotnet-runtime = dotnetCorePackages.dotnet_10.runtime;

  meta = {
    homepage = "https://glidermcp.com/";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    mainProgram = "glider";
  };
}
