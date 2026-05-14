{
  lib,
  buildDotnetGlobalTool,
  dotnetCorePackages,
  ...
}:

buildDotnetGlobalTool {
  pname = "NuGet.Mcp.Server";
  version = "1.4.3";

  nugetName = "NuGet.Mcp.Server.linux-x64";
  nugetHash = "sha256-7kXni4Dj7TGOSevkFz5Fkled2B/gsS8jSFtX5g3q0x4=";
  executables = [ "nuget-mcp-server" ];

  dotnet-sdk = dotnetCorePackages.dotnet_10.sdk;
  dotnet-runtime = dotnetCorePackages.dotnet_10.runtime;

  meta = {
    homepage = "https://github.com/NuGet/Home/";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "nuget-mcp-server";
  };
}
