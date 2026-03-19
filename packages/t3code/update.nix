{
  bun,
  nix,
  pnpm_10,
  nix-update,
  writeShellApplication,
}:

writeShellApplication {
  name = "update-t3code";

  runtimeInputs = [
    bun
    nix
    pnpm_10
    nix-update
  ];

  runtimeEnv.UPDATE_SCRIPT_PATH = "${./update.mts}";

  text = ''
    bun $UPDATE_SCRIPT_PATH "$@"
  '';
}
