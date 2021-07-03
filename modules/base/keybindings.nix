{ pkgs, lib, config, vimLib, ... }:

with lib;

let
  base = config.base;
  cfg = config.base.keybindings;
in {
  options.base.keybindings = {
    keybindings = mkOption {
      type = types.listOf vimLib.types.keymapping;
      description = "A list of keymappings.";
      default = [ ];
    };

    leader = mkOption {
      type = types.str;
      default = "\\\\"; # Nix turns it into \\ which neovim turns into \
      description = "The <leader> key, used for custom keybindings.";
    };
  };

  config = mkMerge [
    {
      output.config_file =
        concatMapStringsSep "\n" (a: "${a.mapCommand} ${a.keys} ${a.action}")
        cfg.keybindings;
    }

    {
      output.config_file = mkBefore (optionalString base.enable ''
        let mapleader="${cfg.leader}"
      '');
    }
  ];
}
