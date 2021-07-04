{ pkgs, lib, config, vimLib, ... }:

with lib;
with builtins;

let
  base = config.base;
  cfg = config.base.options;
in {
  options.base.options = {
    set = mkOption {
      type = with types; attrsOf (oneOf [ bool float int str ]);
      default = { };
      description = "A set of options to 'set <key>=<value>' in vimscript.";
    };

    var = mkOption {
      type = with types; attrsOf (oneOf [ bool float int str ]);
      default = { };
      description = "A set of options to 'let g:<key>=<value>' in vimscript.";
    };
  };

  # https://github.com/nanotee/nvim-lua-guide#managing-vim-options
  config = {
    output.config_file = let
      json_options = pkgs.writeText "nix-neovim-options" (toJSON cfg.set);
      json_globals = pkgs.writeText "nix-neovim-globals" (toJSON cfg.var);
    in ''
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

        local json_options = from_json("${json_options}")
        for k, v in pairs(json_options) do
          vim.o[k] = v
        end

        local json_globals = from_json("${json_globals}")
        for k, v in pairs(json_globals) do
          vim.g[k] = v
        end
      EOF
    '';

  };
}
