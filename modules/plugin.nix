{ pkgs, lib, config, ... }:

with lib;
with builtins;

let
  settingsFormat = pkgs.formats.json { };
  cfg = config.plugin;
in {
  options.plugin = {
    setup = mkOption {
      type = with types;
        attrsOf (submodule { freeformType = settingsFormat.type; });

      default = { };
      description = ''
        A set of options to `require(KEY).setup(VALUE)` in lua.

        This convention is frequently used by lua plugins.
      '';
      example = ''
        plugin.setup."nvim-treesitter.configs" = {
          highlight.enable = true;
        };
      '';
    };
  };

  config = {
    output.config_file = let
      json_setup =
        settingsFormat.generate "nix-neovim-plugin-setup.json" cfg.setup;
    in ''
      lua << EOF
        local from_json = require('nix-neovim.utils').from_json

        for k, v in pairs(from_json("${json_setup}")) do
          require(k).setup(v)
        end
      EOF
    '';
  };
}
