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
      default = false;
      description = "Whether to automatically format when saving.";
    };

    formatters = {
      nixfmt = mkEnableOption "nixfmt formatter";

      stylish-haskell = mkEnableOption "stylish-haskell formatter";

      rustfmt = mkEnableOption "rustfmt formatter";
    };
  };

  config = mkIf cfg.enable {
    output.config_file = ''
      " Necessary for filetype detection
      filetype on
      filetype plugin indent on

      " Format on save (if enabled)
      ${optionalString cfg.fmt_on_save "autocmd BufWritePre * Neoformat"}
    '';

    # Explicitly set the paths to the formatters
    vim.g = {
      neoformat_haskell_stylishhaskell = mkIf cfg.formatters.stylish-haskell {
        exe = "${pkgs.stylish-haskell}/bin/stylish-haskell";
        stdin = true;
      };

      neoformat_nix_nixfmt = mkIf cfg.formatters.nixfmt {
        exe = "${pkgs.nixfmt}/bin/nixfmt";
        stdin = true;
      };

      neoformat_rust_rustfmt = mkIf cfg.formatters.rustfmt {
        exe = "${pkgs.rustfmt}/bin/rustfmt";
        stdin = true;
      };
    };

    output.plugins = with pkgs.vimPlugins; [ neoformat ];
  };
}
