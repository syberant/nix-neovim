{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.nerdcommenter;
  mkEnableOptionTrue = a: mkEnableOption a // { default = true; };
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
        attrsOf (submodule {
          options = {
            left = mkOption {
              type = types.str;
              description = "The 'left' delimiter.";
            };
          };
        });
      default = { };
      description = "Add custom delimiters.";
    };
  };

  config = mkIf cfg.enable {
    vim.g = {
      inherit (cfg)
        NERDSpaceDelims NERDCommentEmptyLines NERDTrimTrailingWhitespace
        NERDCustomDelimiters;
    };

    output.plugins = with pkgs.vimPlugins; [ nerdcommenter ];
  };
}
