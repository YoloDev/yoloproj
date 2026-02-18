{ git-hooks, flakeModules }:
{ lib, ... }:
{
  imports = [
    git-hooks.flakeModule
    flakeModules.dev
  ];

  perSystem =
    { pkgs, config, ... }:
    let
      inherit (pkgs) prek;

    in
    {
      # Some hooks cannot run in a build environment
      pre-commit.check.enable = false;
      pre-commit.settings.package = prek;
      pre-commit.settings.hooks = {
        flake-checker.enable = true;
        nixfmt.enable = true;
      };

      devshells.default =
        { pkgs, ... }:
        {
          commands = [
            {
              name = "prek";
              help = "run pre-commit hooks";
              category = "lint";
              command = ''
                ${prek}/bin/prek run
              '';
            }
          ];

          devshell = {
            # packages = sysCfg.pre-commit.settings.enabledPackages;
            startup.install-git-hooks.text = ''
              # pre-commit installation script
              ${config.pre-commit.installationScript}
            '';
          };
        };
    };
}
