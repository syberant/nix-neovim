{ pkgs, lib, config, ... }:

with lib;

let cfg = config.neoformat;
in {
  options.neoformat = {
    enable = mkEnableOption "Neoformat";

    # TODO: config
    use_path = mkOption {
      type = types.bool;
      default = true;
      description =
        "Whether or not to use formatters from the path when available (less declarative approach).";
    };

    fmt_on_save = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to automatically format when saving.";
    };

    formatters = {
      nixfmt = mkOption {
        type = types.bool;
        default = true;
        description = "Whether or not to enable nixfmt.";
      };

      stylish-haskell = mkOption {
        type = types.bool;
        default = true;
        description = "Whether or not to enable stylish-haskell.";
      };
    };
  };

  config = let
    formatters = [ ] ++ optional cfg.formatters.stylish-haskell ''
      let g:neoformat_haskell_stylishhaskell = {
        \ 'exe' : '${pkgs.stylish-haskell}/bin/stylish-haskell',
        \ 'stdin' : 1,
      \ }
    '' ++ optional cfg.formatters.nixfmt ''
      let g:neoformat_nix_nixfmt = {
        \ 'exe' : '${pkgs.nixfmt}/bin/nixfmt',
        \ 'stdin' : 1,
      \ }
    '';
    format_declarations = builtins.foldl' (a: b: a + "\n" + b) "" formatters;
  in mkIf cfg.enable {
    output.config_file = ''
      ${format_declarations}

      augroup neoformat
        automcd!
        ${optionalString cfg.fmt_on_save "autocmd BufWritePre * Neoformat"}
      augroup END
    '';

    output.plugins = with pkgs.vimPlugins; [ neoformat ];
  };
}
