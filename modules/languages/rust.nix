{ pkgs, lib, config, ... }:

with lib;

let cfg = config.languages.rust;
in {
  options.languages.rust = { enable = mkEnableOption "Rust support"; };

  config = mkIf cfg.enable { neoformat.formatters.rustfmt = true; };
}
