{
  lib,
  bun,
  nix,
  writeShellApplication,
  packages,
}:
let
  packagesWithUpdate = lib.filter (pkg: pkg.update != null) (
    lib.attrsets.mapAttrsToList (name: pkg: {
      inherit name;
      update = pkg.update or null;
    }) packages
  );

  scriptUpdateInput = lib.map (pkg: {
    inherit (pkg) name;
    update = lib.getExe pkg.update;
  }) packagesWithUpdate;
in
writeShellApplication {
  name = "update-packages";

  runtimeInputs = [
    bun
    nix
  ];

  runtimeEnv.UPDATE_SCRIPT_PATH = "${./update.mts}";
  runtimeEnv.PACKAGES = builtins.toJSON scriptUpdateInput;

  excludeShellChecks = [
    # shellcheck doesn't like the JSON stringification, but it's actually correct
    "SC2089"
    "SC2090"
  ];

  text = ''
    bun $UPDATE_SCRIPT_PATH "$@"
  '';
}
