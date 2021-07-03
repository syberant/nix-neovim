{ pkgs, lib, config, vimLib, ... }:

with lib;

let
  base = config.base;
  cfg = config.base.options;
in {
  options.base.options = {
    set = mkOption {
      type = vimLib.types.optionalStringList;
      default = [ ];
      description = "A list of strings to 'set <something>' in vimscript.";
    };

    var = mkOption {
      type = vimLib.types.optionalStringList;
      default = [ ];
      description = "A list of strings to 'let g:<something>' in vimscript.";
    };
  };

  config = mkMerge [
    { output.config_file = concatMapStringsSep "\n" (a: "set ${a}") cfg.set; }

    { output.config_file = concatMapStringsSep "\n" (a: "let g:${a}") cfg.var; }
  ];
}
