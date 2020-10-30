{ pkgs, lib, config, ... }:

with lib;

let cfg = config.languages.nix;
in {
  options.languages.nix = { enable = mkEnableOption "nix support"; };

  config = mkIf cfg.enable {
    neoformat.formatters.nixfmt = true;

    nerdcommenter.NERDCustomDelimiters = [{
      language = "nix";
      left = "#";
    }];

    output.plugins = with pkgs.vimPlugins; [ vim-nix ];
  };
}
