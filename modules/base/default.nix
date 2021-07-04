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
  imports = [ ./files.nix ./keybindings.nix ./options.nix ./search.nix ./wrapping.nix ];

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

    timeoutlen = mkOption {
      type = types.ints.positive;
      default = 1000;
      description =
        "The timeout after which a partial keybinding will be cancelled.";
    };
  };

  config = mkIf cfg.enable {
    base.options.set = {
      # Tabstop
      tabstop = cfg.tabstop;
      softtabstop = cfg.tabstop;
      shiftwidth = cfg.tabstop;

      expandtab = mkIf cfg.expandtab true;

      # Line numbering
      cursorline = mkIf cfg.cursorline true;
      number = mkIf cfg.line-number true;
      relativenumber = mkIf cfg.relativenumber true;
      numberwidth = cfg.line-number-width;

      # Keybinding
      timeoutlen = cfg.timeoutlen;
    };

    output.config_file = optionalString cfg.auto-termguicolors ''
      " Enable 24-bit colours if available
      if has('termguicolors')
        set termguicolors
      endif
    '';
  };
}
