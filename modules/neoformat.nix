{ pkgs, config, ... }:

with pkgs.lib;

let cfg = config.neoformat;
in {
  options.neoformat = {
    enable = mkEnableOption {
      default = false;
      description = "Whether or not to enable Neoformat.";
    };

    # TODO: config
    use_path = mkEnableOption {
      default = true;
      description =
        "Whether or not to use formatters from the path when available (less declarative approach).";
    };

    fmt_on_save = mkEnableOption {
      default = true;
      description = "Whether to automatically format when saving.";
    };

    formatters = {
      nixfmt = mkEnableOption {
        default = true;
        description = "Whether or not to enable nixfmt.";
      };

      stylish-haskell = mkEnableOption {
        default = true;
        description = "Whether or not to enable stylish-haskell.";
      };
    };
  };

  #  config = let
  #    formatters = [
  #      (mkIf cfg.formatters.stylish-haskell ''
  #        let g:neoformat_haskell_stylishhaskell = {
  #          \ 'exe' : '${pkgs.stylish-haskell}/bin/stylish-haskell',
  #          \ 'stdin' : 1,
  #        \ }
  #      '')
  #      (mkIf cfg.formatters.nixfmt ''
  #        let g:neoformat_nix_nixfmt = {
  #          \ 'exe' : '${pkgs.nixfmt}/bin/nixfmt',
  #          \ 'stdin' : 1,
  #        \ }
  #      '')
  #    ];
  #    format_declarations = builtins.foldl' (a: b: a + "\n" + b) "" formatters;
  #  in mkIf cfg.enable {
  #    output.config_file = ''
  #      ''${format_declarations}
  #
  #      augroup neoformat
  #        automcd!
  #        ''${mkIf cfg.fmt_on_save "autocmd BufWritePre * Neoformat"}
  #      augroup END
  #    '';
  #
  #    output.plugins = with pkgs.vimPlugins; [ neoformat ];
  #  };

  config = pkgs.lib.mkIf false { output.config_file = "a"; };
}
