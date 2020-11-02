{ pkgs, lib, config, vimLib, ... }:

with lib;

let cfg = config.vim-surround;
in {
  options.vim-surround = {
    enable = mkEnableOption "the vim-surround plugin";

    vim-repeat = vimLib.mkEnableOptionTrue
      "the vim-repeat plugin which adds the ability to redo vim-surround commands with '.'";
  };

  config = mkIf cfg.enable {
    vim-repeat.enable = mkIf cfg.vim-repeat (mkDefault true);

    output.plugins = with pkgs.vimPlugins; [ vim-surround ];
  };
}
