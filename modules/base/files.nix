{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.base.files;
  mkEnableOptionTrue = a: mkEnableOption a // { default = true; };
in {
  options.base.files = {
    enable = mkEnableOption "{undo,swap} files configuration";

    # swap
    swapdir = mkOption {
      type = types.str;
      description = "The directory for storing swap files.";
      default = "$HOME/.local/share/vim/swap//";
    };

    # undo
    enableUndo = mkEnableOptionTrue "undo file configuration";
    undodir = mkOption {
      type = types.str;
      description = "The directory for storing undo files.";
      default = "$HOME/.local/share/vim/undo";
    };
  };

  config = mkIf cfg.enable {
    base.options.set = mkMerge [
      { directory = cfg.swapdir; }

      (mkIf cfg.enableUndo {
        undofile = true;
        undodir = cfg.undodir;
      })
    ];
  };
}
