{ pkgs, lib, config, ... }:

with lib;

let cfg = config.vim-repeat;
in {
  options.vim-repeat = { enable = mkEnableOption "the vim-repeat plugin"; };

  config =
    mkIf cfg.enable { output.plugins = with pkgs.vimPlugins; [ vim-repeat ]; };
}
