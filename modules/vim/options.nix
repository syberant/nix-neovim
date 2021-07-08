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
          vim.opt[k] = v
        end

        local json_globals = from_json("${json_globals}")
        for k, v in pairs(json_globals) do
          vim.g[k] = v
        end
      EOF
    '';

  };
}
