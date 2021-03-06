{ pkgs, lib, config, ... }:

with lib;

let cfg = config.colourscheme.tokyonight;
in {
  options.colourscheme.tokyonight = {
    enable = mkEnableOption "tokyonight colourscheme";

    style = mkOption {
      type = types.enum [ "storm" "night" "day" ];
      default = "storm";
      description = ''
        The Tokyo Night theme comes in three styles: day, storm and a darker variant night.
        See its README for more information.
      '';
    };
  };

  config = mkIf cfg.enable {
    vim.g.tokyonight_style = cfg.style;

    vim.g.lightline.colorscheme = "tokyonight";

    output.config_file = ''
      colo tokyonight
    '';

    output.plugins = with pkgs;
      [
        (vimUtils.buildVimPluginFrom2Nix {
          name = "tokyonight.nvim";
          src = fetchFromGitHub {
            owner = "folke";
            repo = "tokyonight.nvim";
            rev = "0ead86afe390603f9bd688103d7a5fc6724a828e";
            sha256 = "BCF5J4iCbccFEkc8gi5tkmbOrb8ZCjaDlbheVRXT0NA=";
          };
        })
      ];
  };
}
