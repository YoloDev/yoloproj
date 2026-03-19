{
  lib,
  buildDotnetGlobalTool,
  dotnetCorePackages,
  emptyDirectory,
}:

(buildDotnetGlobalTool {
  pname = "glider";
  version = "5.7.0";

  nugetHash = "sha256-lGFNRB2JzB9MlGLvpKrST3d7Qcb2V/mGs74QZTPLGkQ=";

  dotnet-sdk = dotnetCorePackages.dotnet_10.sdk;
  dotnet-runtime = dotnetCorePackages.dotnet_10.runtime;

  meta = {
    homepage = "https://glidermcp.com/";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    mainProgram = "glider";
  };
}).overrideAttrs
  (
    prev: # This makes nix-update find the correct file
    {
      inherit (prev) version;
      src = emptyDirectory;
    }
  )
