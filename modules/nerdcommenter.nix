{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.nerdcommenter;
  mkEnableOptionTrue = a: mkEnableOption a // { default = true; };
  boolToVim = b: if b then "1" else "0";
in {
  options.nerdcommenter = {
    enable = mkEnableOption "nerdcommenter plugin";

    NERDSpaceDelims =
      mkEnableOptionTrue "adding spaces after comment delimiters";
    NERDCommentEmptyLines =
      mkEnableOption "commenting and inverting empty lines";
    NERDTrimTrailingWhitespace = mkEnableOptionTrue
      "automatic trimming of trailing whitespace when uncommenting";
    NERDCustomDelimiters = mkOption {
      type = with types;
        listOf (submodule {
          options = {
            language = mkOption {
              type = types.str;
              description = "The language for this custom delimiter.";
            };
            left = mkOption {
              type = types.str;
              description = "The 'left' delimiter.";
            };
          };
        });
      default = [ ];
      description = "Add custom delimiters.";
    };
  };

  config = mkIf cfg.enable {
    output.config_file = ''
      let g:NERDSpaceDelims = ${boolToVim cfg.NERDSpaceDelims}
      let g:NERDCommentEmptyLines = ${boolToVim cfg.NERDCommentEmptyLines}
      let g:NERDTrimTrailingWhitespace = ${
        boolToVim cfg.NERDTrimTrailingWhitespace
      }
    '' + (optionalString (cfg.NERDCustomDelimiters != [ ]) (''
      let g:NERDCustomDelimiters = {
    '' + (foldl' (a: b: a + "  \\ '${b.language}' : { 'left': '${b.left}' },\n")
      "" cfg.NERDCustomDelimiters) + ''
        \ }
      ''));

    output.plugins = with pkgs.vimPlugins; [ nerdcommenter ];
  };
}
