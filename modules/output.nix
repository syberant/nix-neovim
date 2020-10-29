{ pkgs, ... }:

with pkgs.lib;

{
  options.output = {
    config_file = mkOption {
      type = types.lines;
      default = "";
    };

    plugins = mkOption {
      type = with types; listOf package;
      default = [ ];
    };
  };
}
