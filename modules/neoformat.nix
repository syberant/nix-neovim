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
      nixfmt = mkEnableOption "nixfmt formatter";

      stylish-haskell = mkEnableOption "stylish-haskell formatter";

      rustfmt = mkEnableOption "rustfmt formatter";
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
    '' ++ optional cfg.formatters.rustfmt ''
      let g:neoformat_rust_rustfmt = {
        \ 'exe' : '${pkgs.rustfmt}/bin/rustfmt',
        \ 'stdin' : 1,
      \ }
    '';
    format_declarations = builtins.foldl' (a: b: a + "\n" + b) "" formatters;
  in mkIf cfg.enable {
    output.config_file = ''
      " Necessary for filetype detection
      filetype on
      filetype plugin indent on

      " Explicitly set the paths to the formatters
      ${format_declarations}

      " Format on save (if enabled)
      ${optionalString cfg.fmt_on_save "autocmd BufWritePre * Neoformat"}
    '';

    output.plugins = with pkgs.vimPlugins; [ neoformat ];
  };
}
