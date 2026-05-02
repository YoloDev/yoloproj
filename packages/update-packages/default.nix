{
  lib,
  bun,
  nix,
  writeShellApplication,
  packages,
  ...
}:
let
  packagesWithUpdate = lib.filter (pkg: pkg.update != null) (
    lib.attrsets.mapAttrsToList (name: pkg: {
      inherit name;
      update = pkg.update or null;
    }) packages
  );

  mkUpdatePackage =
    name: pkg:
    let
      package =
        if builtins.isList pkg then
          writeShellApplication {
            name = "update-${name}";

            text = builtins.unsafeDiscardStringContext (lib.strings.escapeShellArgs (pkg ++ [ name ]));
          }
        else
          pkg;

    in
    lib.getExe package;

  scriptUpdateInput = lib.map (pkg: {
    inherit (pkg) name;
    update = mkUpdatePackage pkg.name pkg.update;
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
