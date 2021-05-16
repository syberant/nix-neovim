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

    pure = mkOption {
      type = types.bool;
      default = false;
      description = "Sets the PATH to disable binaries on your PATH, helps maintain purity.";
    };

    path = mkOption {
      type = with types; listOf package;
      default = [ ];
      description =
        "PATH available to neovim, `output.pure` determines whether this complements your PATH or replaces it.";
      example = ''
        output.path = with pkgs; makeBinPath pkgs.stdenv.initialPath;
      '';
    };

    makeWrapper = mkOption {
      type = types.separatedString " \\\n";
      default = "";
      description = "Args to pass to the makeWrapper command.";
      example = ''
        output.makeWrapper = with pkgs; "--set PATH ${
          makeBinPath [ coreutils gnused gawk gnugrep ]
        }";
      '';
    };
  };

  config = {
    output.config_file = mkAfter cfg.extraConfig;
    output.makeWrapper = (if cfg.pure then "--prefix PATH : " else "--set PATH ") + makeBinPath cfg.path;
  };
}
