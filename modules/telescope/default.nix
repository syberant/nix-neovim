{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.telescope;
in {
  options.telescope = {
    enable = mkEnableOption "telescope.nvim plugin";
  };

  config = mkIf cfg.enable {
    output.path.path = with pkgs; [ fd ripgrep ];

    output.plugins = with pkgs.vimPlugins; [ telescope-nvim ];
  };
}
