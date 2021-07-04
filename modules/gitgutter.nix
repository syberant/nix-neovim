{ pkgs, lib, config, ... }:

with lib;

# NOTE: this plugin might not work completely in a pure environment.
# Git is integrated however.

let
  cfg = config.gitgutter;
  mkEnableOptionTrue = a: mkEnableOption a // { default = true; };
in {
  options.gitgutter = {
    enable = mkEnableOption "gitgutter plugin";

    onSave = mkEnableOptionTrue "refreshing the signs on save";

    onInsertLeave =
      mkEnableOptionTrue "refreshing the signs when leaving insert mode";
  };

  config = mkIf cfg.enable {
    base.options.var.gitgutter_git_executable = "${pkgs.git}/bin/git";

    output.config_file = optionalString cfg.onSave ''
      autocmd BufWritePost,InsertLeave * GitGutter
    '' + optionalString cfg.onInsertLeave ''
      autocmd InsertLeave * GitGutter
    '';

    output.plugins = with pkgs.vimPlugins; [ gitgutter ];
  };
}
