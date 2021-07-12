{ pkgs, lib, config, vimLib, ... }:

with lib;
with builtins;

let
  settingsFormat = pkgs.formats.json {};
  cfg = config.vim;
in {
  options.vim = {
    opt = mkOption {
      type = with types; submodule {
        freeformType = settingsFormat.type;
      };
      default = { };
      description = "A set of options to 'set <key>=<value>' in vimscript.";
    };

    g = mkOption {
      type = with types; submodule {
        freeformType = settingsFormat.type;
      };
      default = { };
      description = "A set of options to 'let g:<key>=<value>' in vimscript.";
    };
  };

  # https://github.com/nanotee/nvim-lua-guide#managing-vim-options
  config = {
    output.config_file = let
      json_options = settingsFormat.generate "nix-neovim-options.json" cfg.opt;
      json_globals = settingsFormat.generate "nix-neovim-globals.json" cfg.g;
    in ''
      lua << EOF
        local from_json = require('nix-neovim-utils').from_json

        for k, v in pairs(from_json("${json_options}")) do
          vim.opt[k] = v
        end

        for k, v in pairs(from_json("${json_globals}")) do
          vim.g[k] = v
        end
      EOF
    '';

  };
}
