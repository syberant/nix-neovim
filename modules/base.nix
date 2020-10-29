{ pkgs, lib, config, ... }:

with lib;

let cfg = config.base;
in {
  options.base = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable the base module.";
    };

    expandtab = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to turn tabs into spaces when you type them.";
    };

    tabstop = mkOption {
      type = types.ints.positive;
      default = 4;
      description = "How many spaces a tab is.";
    };
  };

  config = mkIf cfg.enable {
    output.config_file = ''
      ${optionalString cfg.expandtab "set expandtab"}

      set tabstop=${toString cfg.tabstop}
      set softtabstop=${toString cfg.tabstop}
      set shiftwidth=${toString cfg.tabstop}
    '';
  };
}
