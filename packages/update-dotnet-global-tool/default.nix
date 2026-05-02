{
  bun,
  nix,
  nix-update,
  writeShellApplication,
  ...
}:

writeShellApplication {
  name = "update-dotnet-global-tool";

  runtimeInputs = [
    bun
    nix
    nix-update
  ];

  runtimeEnv.EVAL_PATH = "${./eval.nix}";
  runtimeEnv.UPDATE_SCRIPT_PATH = "${./update.mts}";

  text = ''
    bun $UPDATE_SCRIPT_PATH "$@"
  '';
}
