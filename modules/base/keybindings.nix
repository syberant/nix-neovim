{ pkgs, lib, config, vimLib, ... }:

with lib;
with builtins;

let
  base = config.base;
  cfg = config.base.keybindings;
in {
  options.base.keybindings = {
    # TODO: Allow keybindings to be declared as a tree
    # keybindings = mkOption {
    # # TODO: Proper typechecking
    # type = types.attrs;
    # description = "A list of keymappings.";
    # default = { };
    # };

    keybindings-shortened = mkOption {
      description =
        "A list of keymappings with all keys of a combination wrapped into one string, i.e. no tree of keybindings.";
      # readOnly = true;
      default = { };

      type = with types;
        attrsOf (submodule {
          options = {
            modes = mkOption {
              # https://github.com/nanotee/nvim-lua-guide#defining-mappings
              type = enum [ "" "n" "v" "s" "x" "o" "!" "i" "l" "c" "t" ];
              default = "";
              description = ''
                The mode(s) in which this keybinding should apply.

                For more information see:
                - `:help map-modes`
                - https://github.com/nanotee/nvim-lua-guide#defining-mappings
              '';
            };

            command = mkOption {
              # TODO: Offer a way to distinguish between lua code and viml commands
              type = str;
              description = ''
                TODO
              '';
            };

            options =
              genAttrs [ "noremap" "nowait" "silent" "script" "expr" "unique" ]
              (opt:
                mkOption {
                  # TODO: make nullable and filter out nulls?
                  type = bool;
                  default = false;

                  description = ''
                    Whether to add '<${opt}>' to the mapping.

                    For more information see:
                    - `:help :map-arguments`
                    - https://github.com/nanotee/nvim-lua-guide#defining-mappings
                  '';
                });
          };
        });
    };

    leader = mkOption {
      type = types.str;
      default = "\\\\"; # Nix turns it into \\ which neovim turns into \
      description = "The <leader> key, used for custom keybindings.";
    };

    which-key-nvim = mkEnableOption "the which-key.nvim plugin";
  };

  config = {
    # base.keybindings.keybindings-shortened = cfg.keybindings;

    # FIXME: Mapleader somehow not working?
    # base.options.var.mapleader = cfg.leader;

    output.config_file = let
      keybindings-shortened = pkgs.writeText "nix-neovim-keybindings-shortened"
        (toJSON cfg.keybindings-shortened);
      # TODO: Support whichkey
      keybindings-whichkey = keybindings-shortened;
    in ''
      let g:mapleader = "${cfg.leader}"

      lua << EOF
        -- https://stackoverflow.com/questions/11201262/how-to-read-data-from-a-file-in-lua
        local function from_json(path)
            local file = io.open(path, "rb") -- r read mode and b binary mode
            if not file then return nil end
            local content = file:read "*a" -- *a or *all reads the whole file
            file:close()

            local ok, res = pcall(vim.fn.json_decode, content)
            if ok then
              return res
            else
              -- TODO: Give error message in a good way
            end
        end

        ${
          if cfg.which-key-nvim then ''
            -- TODO: Support whichkey
            -- local wk = require("which-key")
            -- wk.register(from_json("${keybindings-whichkey}"))
          '' else ''
            for k, v in pairs(from_json("${keybindings-shortened}")) do
              vim.api.nvim_set_keymap(v.modes, k, v.command, v.options)
            end
          ''
        }
      EOF
    '';

    output.plugins = with pkgs.vimPlugins;
      optional cfg.which-key-nvim which-key-nvim;

    # Recommended in README, delay after which the guide opens
    base.timeoutlen = mkIf cfg.which-key-nvim (mkDefault 500);
  };
}
