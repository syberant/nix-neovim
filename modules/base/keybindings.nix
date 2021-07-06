{ pkgs, lib, config, vimLib, ... }:

with lib;
with builtins;

let
  base = config.base;
  cfg = config.base.keybindings;

  binding-type = with types;
    submodule {
      options = {
        command = mkOption {
          # TODO: Offer a way to distinguish between lua code and viml commands
          type = str;
          description = ''
            The command to be executed, presumed to be in vimscript for now.

            TODO: Extra explanation
          '';
        };

        label = mkOption {
          type = str;
          default = "label";
          example = ''"Toggle Comment"'';
          description = ''
            The label shown by which-key.nvim for this keybinding.
          '';
        };

        mode = mkOption {
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
    };
in {
  options.base.keybindings = {
    keybindings = mkOption {
      # TODO: Proper typechecking
      type = with types; attrsOf anything;
      description = "A list of keymappings.";
      default = { };
    };

    keybindings-shortened = mkOption {
      description =
        "A list of keymappings with all keys of a combination wrapped into one string, i.e. no tree of keybindings.";
      # Keeping this open for now as it provides better typechecking
      # readOnly = true;
      default = { };

      type = types.attrsOf binding-type;
    };

    leader = mkOption {
      type = types.str;
      default = "\\\\"; # Nix turns it into \\ which neovim turns into \
      description = "The <leader> key, used for custom keybindings.";
    };

    which-key-nvim = mkEnableOption "the which-key.nvim plugin";
  };

  config = {
    # FIXME: Very hacky.
    base.keybindings.keybindings-shortened = let
      # kv-pair :: Attrs<recursive_path,keybinding> -> Attrs<path, {name = path; value = keybinding;}>
      kv-pair = mapAttrsRecursiveCond (set: !set ? command)
        (path: v: nameValuePair (concatStrings path) v);

      # kv-list :: Attrs<path, {name = path; value = keybinding;}> -> [{name = path; value = keybinding;}]
      kv-list = x: collect (set: set ? name) (kv-pair x);

      # shorten ::Attrs<recursive_path,keybinding> -> Attrs<path,keybinding>
      shorten = x: listToAttrs (kv-list x);
    in shorten cfg.keybindings;

    # FIXME: Mapleader somehow not working?
    # base.options.var.mapleader = cfg.leader;

    output.config_file = let
      keybindings-json = pkgs.writeText "nix-neovim-keybindings-shortened"
        (toJSON cfg.keybindings-shortened);
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
            local wk = require("which-key")

            -- A bit hacky, should be able to do all at once by reshaping the attribute set on the Nix side
            -- but performance doesn't seem to be impacted much and this way is easier so I'll keep it for now
            for k, v in pairs(from_json("${keybindings-json}")) do
              -- which-key.nvim doesn't appear to support the following options: script, nowait, unique
              -- https://github.com/folke/which-key.nvim/blob/2d2954a1d05b4f074e022e64db9aa6093d439bb0/lua/which-key/keys.lua#L191
              wk.register({ [k] = { v.command, v.label, mode=v.mode, noremap=v.options.noremap, silent=v.options.silent, expr=v.options.expr }})
            end
          '' else ''
            for k, v in pairs(from_json("${keybindings-json}")) do
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
