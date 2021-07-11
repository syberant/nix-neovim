{ pkgs, lib, config, ... }:

with lib;

let cfg = config.colourscheme.gruvbox;
in {
  options.colourscheme.gruvbox = {
    enable = mkEnableOption "gruvbox colourscheme";
  };

  config = mkIf cfg.enable {
    output.config_file = ''
      colo gruvbox
    '';

    vim.g.lightline.colorscheme = "gruvbox";

    output.plugins = with pkgs.vimPlugins; [ gruvbox ];
  };
}
