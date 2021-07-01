{ pkgs, lib, config, ... }:

with lib;

let cfg = config.vim-tmux-navigator;
in {
  options.vim-tmux-navigator = {
    enable = mkEnableOption
      "the vim-tmux-navigator plugin, requires additional configuration of tmux.";
  };

  config = mkIf cfg.enable {
    output.plugins = with pkgs.vimPlugins; [ vim-tmux-navigator ];
  };
}
