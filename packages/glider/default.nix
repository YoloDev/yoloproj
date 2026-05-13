{
  lib,
  buildDotnetGlobalTool,
  dotnetCorePackages,
  ...
}:

buildDotnetGlobalTool {
  pname = "glider";
  version = "6.11.3";

  nugetHash = "sha256-x5XCnjJa7un4MIIu06uN0wynjMV/HgNByEYzlDcv/T0=";

  dotnet-sdk = dotnetCorePackages.dotnet_10.sdk;
  dotnet-runtime = dotnetCorePackages.dotnet_10.runtime;

  meta = {
    homepage = "https://glidermcp.com/";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    mainProgram = "glider";
  };
}
