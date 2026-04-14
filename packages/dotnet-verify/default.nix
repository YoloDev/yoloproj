{
  lib,
  buildDotnetGlobalTool,
  dotnetCorePackages,
}:

buildDotnetGlobalTool {
  pname = "verify.tool";
  version = "0.7.0";

  nugetHash = "sha256-s1KDEMyreB8qiEYeJ63qt0bf5aiRff15TTx8LDSt52w=";
  executables = [ "dotnet-verify" ];

  dotnet-sdk = dotnetCorePackages.dotnet_10.sdk;
  dotnet-runtime = dotnetCorePackages.dotnet_10.runtime;

  meta = {
    homepage = "https://github.com/VerifyTests/Verify.Terminal/";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "dotnet-verify";
  };
}
