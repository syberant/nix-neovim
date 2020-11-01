{ pkgs, lib, config, vimLib, ... }:

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
  imports = [ ./search.nix ./wrapping.nix ];

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

    # All the things to "set"
    set = mkOption {
      type = vimLib.types.optionalStringList;
      default = [ ];
      description = "A list of strings to 'set <something>' in vimscript.";
    };
  };

  config = mkMerge [
    { output.config_file = concatMapStringsSep "\n" (a: "set ${a}") cfg.set; }

    (mkIf cfg.enable {
      base.set = [
        # Tabstop
        "tabstop=${toString cfg.tabstop}"
        "softtabstop=${toString cfg.tabstop}"
        "shiftwidth=${toString cfg.tabstop}"
        [
          cfg.expandtab
          "expandtab"
        ]

        # Line numbering
        [ cfg.cursorline "cursorline" ]
        [ cfg.line-number "number" ]
        [ cfg.relativenumber "relativenumber" ]
        "numberwidth=${toString cfg.line-number-width}"
      ];

      output.config_file = ''
        ${optionalString cfg.auto-termguicolors ''
          " Enable 24-bit colours if available
          if has('termguicolors')
            set termguicolors
          endif
        ''}

        " Keybindings
        let mapleader = "${cfg.leader}"
      '';
    })
  ];
}
