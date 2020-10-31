{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.base.search;
  mkEnableOptionTrue = a: mkEnableOption a // { default = true; };
in {
  options.base.search = {
    enable = mkEnableOption "search configuration";

    ignorecase =
      mkEnableOptionTrue "ignoring case when searching in lowercase letters";
    smartcase = mkEnableOptionTrue
      "case-sensitive search when using (a) uppercase letter(s)";
    incsearch = mkEnableOptionTrue "incsearch";
    hlsearch = mkEnableOptionTrue "hlsearch";

    # Off by default as it can be confusing
    gdefault =
      mkEnableOption "defaulting to replacing all occurences on a line";

    # TODO: optional keybinding for running :nohlsearch for clearing all those matches.
  };

  config = mkIf cfg.enable {
    output.config_file = ''
      ${optionalString cfg.ignorecase "set ignorecase"}
      ${optionalString cfg.smartcase "set smartcase"}
      ${optionalString cfg.incsearch "set incsearch"}
      ${optionalString cfg.hlsearch "set hlsearch"}

      ${optionalString cfg.gdefault "set gdefault"}
    '';
  };
}
