{ pkgs, ... }:

with pkgs.lib;

{
  options.output = {
    config_file = mkOption {
      type = types.str;
      default = "";
    };

    plugins = mkOption {
      type = with types; listOf package;
      default = [ ];
    };
  };
}
