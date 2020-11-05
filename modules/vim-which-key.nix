{ pkgs, lib, config, vimLib, ... }:

with lib;

let cfg = config.vim-which-key;
in {
  options.vim-which-key = {
    enable = mkEnableOption "the vim-which-key plugin";

    showkeys = mkOption {
      type = with types; listOf str;
      default = [ ];
      description = "Shows the keybindings on these keys";
    };

    timeout = mkAliasDefinitions options.base.timeoutlen;
  };

  config = mkIf cfg.enable {
    output.config_file = concatMapStringsSep "\n" (a: ''
      nnoremap <silent> ${a} :WhichKey '${a}'<CR>
    '') cfg.showkeys;
    output.plugins = with pkgs.vimPlugins; [ vim-which-key ];
  };
}
