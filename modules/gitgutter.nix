{ pkgs, lib, config, ... }:

with lib;

# NOTE: this plugin doesn't work without access to some tools on PATH, it uses at least git and grep but still some others I still have to find out.
# TODO: integrate all runtime dependencies

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
    output.config_file = optionalString cfg.onSave ''
      autocmd BufWritePost,InsertLeave * GitGutter
    '' + optionalString cfg.onInsertLeave ''
      autocmd InsertLeave * GitGutter
    '';

    output.plugins = with pkgs.vimPlugins; [ gitgutter ];
  };
}
