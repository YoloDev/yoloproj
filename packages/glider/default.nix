{
  lib,
  buildDotnetGlobalTool,
  dotnetCorePackages,
}:

buildDotnetGlobalTool {
  pname = "glider";
  version = "6.0.0";

  nugetHash = "sha256-4AjiW/S+W88ruPCcK+MvLnrWj6BQkxxybVdtWMvfhxs=";

  dotnet-sdk = dotnetCorePackages.dotnet_10.sdk;
  dotnet-runtime = dotnetCorePackages.dotnet_10.runtime;

  meta = {
    homepage = "https://glidermcp.com/";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    mainProgram = "glider";
  };
}
