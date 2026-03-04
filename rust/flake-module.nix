{ flakeModules, rust-overlay }:
{ lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

in
{
  imports = [
    flakeModules.project
  ];

  perSystem =
    { config, pkgs, ... }:
    let
      cfg = config.project.rust;
      fmtCfg = config.project.formatting.formatters.rustfmt or null;

    in
    {
      options.project.rust = {
        enable = mkEnableOption "Enable the project module" // {
          default = true;
        };

        toolchainFile = mkOption {
          type = types.nullOr types.path;
          description = "Path to the rust toolchain file";
          default = null;
        };

        package = mkOption {
          type = types.package;
          description = "Rust package to use";
          default =
            assert cfg.enable;
            if cfg.toolchainFile == null then
              pkgs.rust-bin.stable.latest.default
            else
              pkgs.rust-bin.fromRustupToolchainFile cfg.toolchainFile;
        };
      };

      config = mkIf cfg.enable {
        pkgs.overlays = [ (import rust-overlay) ];

        project.formatting.formatters.rustfmt = {
          inherit (cfg) package;
          files.pass = false;
          files.extensions.rs = true;
          commands.format = "${fmtCfg.package}/bin/cargo-fmt fmt --all -- '--color=always'";
          commands.check = "${fmtCfg.package}/bin/cargo-fmt fmt --check --all -- '--color=always'";
        };

        # TODO: use project.linters
        pre-commit.settings.hooks.clippy = {
          enable = true;
          settings.denyWarnings = true;
          settings.extraArgs = "--all";
          settings.offline = false;

          package = cfg.package;
          packageOverrides.cargo = cfg;
          packageOverrides.clippy = cfg;
        };

        devshells.default =
          { ... }:
          {
            packages = [
              # rust, cargo, clippy, et al
              cfg.package

              # dev env
              pkgs.crates-lsp
              pkgs.package-version-server
            ];
          };
      };
    };
}
