{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.base;
  mkEnableOptionTrue = text:
    mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable ${text}.";
    };
in {
  imports = [ ./search.nix ];

  options.base = {
    enable = mkEnableOptionTrue "the base module";

    expandtab = mkEnableOptionTrue "turning tabs into spaces when typed";
    tabstop = mkOption {
      type = types.ints.positive;
      default = 4;
      description = "How many spaces a tab is.";
    };

    auto-termguicolors = mkEnableOptionTrue
      "automatically enabling 24-bit colours when the terminal supports it";

    # Line numbering
    cursorline =
      mkEnableOptionTrue "highlighting the screen line of the cursor";
    line-number = mkEnableOptionTrue "line numbering";
    relativenumber = mkEnableOptionTrue "relative line numbering";
    line-number-width = mkOption {
      type = types.ints.positive;
      default = 3;
      description = "The amount of space line numbering takes up.";
    };

    # Keybindings
    leader = mkOption {
      type = types.str;
      default = "\\\\"; # Nix turns it into \\ which neovim turns into \
      description = "The <leader> key, used for custom keybindings.";
    };
  };

  config = mkIf cfg.enable {
    output.config_file = ''
      ${optionalString cfg.expandtab "set expandtab"}

      set tabstop=${toString cfg.tabstop}
      set softtabstop=${toString cfg.tabstop}
      set shiftwidth=${toString cfg.tabstop}

      ${optionalString cfg.auto-termguicolors ''
        if has('termguicolors')
          set termguicolors
        endif
      ''}

      " line numbering
      ${optionalString cfg.cursorline "set cursorline"}
      ${optionalString cfg.line-number "set number"}
      ${optionalString cfg.relativenumber "set relativenumber"}
      set numberwidth=${toString cfg.line-number-width}

      " Keybindings
      let mapleader = "${cfg.leader}"
    '';
  };
}
