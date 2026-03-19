{
  bun,
  nix,
  nix-update,
  writeShellApplication,
}:

writeShellApplication {
  name = "update-dotnet-global-tool";

  runtimeInputs = [
    bun
    nix
    nix-update
  ];

  runtimeEnv.EVAL_PATH = ./eval.nix;

  text = ''
    bun ${./update.mts} "$@"
  '';
}
