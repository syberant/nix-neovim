{ pkgs, lib, config, ... }:

with lib;

let cfg = config.which-key-nvim;
in {
  options.which-key-nvim = {
    enable = mkEnableOption "the which-key.nvim plugin";
  };

  config = mkIf cfg.enable {
    output.plugins = with pkgs.vimPlugins; [ which-key-nvim ];

    # Recommended in README, delay after which the guide opens
    base.timeoutlen = mkDefault 500;
  };
}
