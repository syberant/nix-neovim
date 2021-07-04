{ pkgs, lib, config, ... }:

with lib;

let cfg = config.lightline;
in {
  options.lightline = {
    enable = mkEnableOption "lightline plugin";

    useDefault = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to use my default config.";
    };

    colourscheme = mkOption {
      type = with types; nullOr str;
      default = null;
      description = "Colourscheme for lightline to use.";
    };
  };

  config = mkIf cfg.enable {
    base.options.set.showmode = mkIf cfg.useDefault false;

    base.options.var.lightline = mkIf cfg.useDefault {
      colorscheme = mkIf (cfg.colourscheme != null) cfg.colourscheme;

      active = {
        left = [ [ "mode" "paste" ] [ "readonly" "filename" "modified" ] ];
        right = [
          [ "lineinfo" ]
          [ "percent" ]
          [ "fileformat" "fileencoding" "filetype" ]
        ];
      };
    };

    output.plugins = with pkgs.vimPlugins; [ lightline-vim ];
  };
}
