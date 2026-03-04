{
  ...
}:
{
  perSystem =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib)
        mkOption
        mkEnableOption
        mkIf
        types
        ;

      projCfg = config.project;
      cfg = projCfg.formatting;

      mkAllCommand =
        {
          name,
          extensions,
          command,
        }:
        let
          enabledExtensions = lib.filterAttrs (extName: enabled: enabled) extensions;
          extensionNames = lib.mapAttrsToList (extName: enabled: extName) enabledExtensions;
          escapedExtensionNames = lib.map (ext: lib.strings.escapeShellArg "*.${ext}") extensionNames;
          spaceSeparatedExtensions = lib.concatStringsSep " " escapedExtensionNames;

        in
        pkgs.writeShellApplication {
          inherit name;

          runtimeInputs = [ pkgs.git ];

          text = ''
            git ls-files --exclude-standard --others --cached --modified  -- ${spaceSeparatedExtensions} | xargs ${command}
          '';
        };

      getExeStr =
        stringOrDerivation:
        if lib.isString stringOrDerivation then stringOrDerivation else lib.getExe stringOrDerivation;

      mkCheckAllCommand =
        config:
        if !config.files.pass then
          config.commands.check
        else
          mkAllCommand {
            name = "${config.name}-check-all";
            extensions = config.files.extensions;
            command = getExeStr config.commands.check;
          };

      mkFormatAllCommand =
        config:
        if !config.files.pass then
          config.commands.format
        else
          mkAllCommand {
            name = "${config.name}-format-all";
            extensions = config.files.extensions;
            command = getExeStr config.commands.format;
          };

      commandType = lib.types.pathInStore;

      formatterType = types.submodule (
        { name, config, ... }:
        {
          options = {
            name = mkOption {
              type = types.str;
              description = "The name of the formatter";
              readOnly = true;
            };

            enable = mkEnableOption "Enable the formatter" // {
              default = true;
            };

            package = mkOption {
              type = types.package;
              description = "The package that provides the formatter";
            };

            commands.format = mkOption {
              type = commandType;
              description = "The command to format a set of files, the files are provided as arguments";
            };

            commands.formatAll = mkOption {
              type = commandType;
              description = "The command to format all files in the project";
              default = mkFormatAllCommand config;
            };

            commands.check = mkOption {
              type = types.nullOr commandType;
              description = "The command to check a set of files, the files are provided as arguments";
              default = null;
            };

            commands.checkAll = mkOption {
              type = types.nullOr commandType;
              description = "The command to check all files in the project";
              default = if config.commands.check == null then null else (mkCheckAllCommand config);
            };

            files.pass = mkOption {
              type = types.bool;
              description = "Whether to pass the files to the formatter";
              default = true;
            };

            files.extensions = mkOption {
              type = types.attrsOf types.bool;
              description = "The file extensions that this formatter supports";
              default = { };
            };
          };

          config = {
            inherit name;
          };
        }
      );

    in
    {
      imports = [
        ./formatters/nixfmt.nix
      ];

      options.project.formatting = {
        enable = mkEnableOption "Enable formatting" // {
          default = true;
        };

        formatters = mkOption {
          type = types.lazyAttrsOf formatterType;
          description = "Formatters used by the project";
          default = { };
        };
      };

      config =
        let
          mkAllPackage =
            {
              name,
              formatters,
              getCommand,
            }:
            let
              enabledFormatters = lib.filterAttrs (name: fmtCfg: fmtCfg.enable) formatters;
              candidateFormatterPackages = lib.mapAttrsToList (name: fmtCfg: getCommand fmtCfg) enabledFormatters;
              formatterPackages = lib.filter (command: command != null) candidateFormatterPackages;
              formatterCommands = lib.map getExeStr formatterPackages;

            in
            pkgs.writeShellApplication {
              inherit name;

              text = lib.concatStringsSep "\n" formatterCommands;
            };

          formatAllPackage = mkAllPackage {
            name = "fmt-format-all";
            formatters = cfg.formatters;
            getCommand = fmtCfg: fmtCfg.commands.formatAll;
          };

          checkAllPackage = mkAllPackage {
            name = "fmt-check-all";
            formatters = cfg.formatters;
            getCommand = fmtCfg: fmtCfg.commands.checkAll;
          };

        in
        mkIf (projCfg.enable && cfg.enable) {
          devshells.default.commands = [
            {
              name = "fmt-format-all";
              help = "format all files";
              category = "formatting";
              command = getExeStr formatAllPackage;
            }
            {
              name = "fmt-check-all";
              help = "check all files";
              category = "formatting";
              command = getExeStr checkAllPackage;
            }
          ];

          pre-commit.settings.hooks =
            let
              enabledFormatters = lib.filterAttrs (name: fmtCfg: fmtCfg.enable) cfg.formatters;
              formatterCheckHooks = lib.mapAttrs (
                name: fmtCfg:
                let
                  enabledExtensions = lib.filterAttrs (extName: enabled: enabled) fmtCfg.files.extensions;
                  extensionNames = lib.mapAttrsToList (extName: enabled: extName) enabledExtensions;
                  escapedExtensionNames = lib.map lib.strings.escapeRegex extensionNames;
                  filesPattern = lib.strings.join "|" escapedExtensionNames;
                  files = "\\.(${filesPattern})$";

                in
                {
                  enable = true;
                  name = name;
                  files = files;
                  pass_filenames = fmtCfg.files.pass;
                  entry = getExeStr fmtCfg.commands.format;
                }
              ) enabledFormatters;
            in
            formatterCheckHooks;
        };
    };
}
