{ pkgs, config, ... }:

with pkgs.lib;

let cfg = config.output;
in {
  options.output = {
    config_file = mkOption {
      type = types.lines;
      default =
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
  };

  config = { output.config_file = mkAfter cfg.extraConfig; };
}
