{ pkgs, lib, config, ... }:

with lib;

let cfg = config.languages.haskell;
in {
  options.languages.haskell = { enable = mkEnableOption "haskell support"; };

  config = mkIf cfg.enable { neoformat.formatters.stylish-haskell = true; };
}
