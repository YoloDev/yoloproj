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
      # options = {

      # };

      config = {
        # Some hooks cannot run in a build environment
        pre-commit.check.enable = false;
        pre-commit.settings.package = prek;
        pre-commit.settings.hooks = {
          flake-checker.enable = true;
        };

        devshells.default =
          { ... }:
          {
            commands = [
              {
                name = "prek";
                help = "run pre-commit hooks";
                category = "lint";
                command = ''
                  exec ${prek}/bin/prek $@
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
    };
}
