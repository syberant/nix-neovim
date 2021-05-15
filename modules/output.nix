{ pkgs, config, ... }:

with pkgs.lib;

let cfg = config.output;
in {
  options.output = {
    config_file = mkOption {
      type = types.lines;
      default = "";
      description =
        "Raw text ending up in config file, this is used internally by all modules, please use extraConfig instead to place your extra configuration after nix-neovim's automated one.";
    };

    plugins = mkOption {
      type = with types; listOf package;
      default = [ ];
      description = "Escape hatch for extra plugins.";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Escape hatch for extra configuration.";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.neovim-unwrapped;
      description = "Unwrapped neovim binary.";
    };

    makeWrapper = mkOption {
      type = types.separatedString " \\\n";
      default = "";
      description = "Args to pass to the makeWrapper command.";
      example = ''
        output.makeWrapper = "--set PATH ${
          makeBinPath [ coreutils gnused gawk gnugrep ]
        }";
      '';
    };

    enableDevConfig = mkEnableOption "nix-neovim development configuration, helps maintain purity.";
  };

  config = {
    output.config_file = mkAfter cfg.extraConfig;
    output.makeWrapper = with pkgs; mkIf cfg.enableDevConfig "--set PATH ${makeBinPath stdenv.initialPath}";
  };
}
