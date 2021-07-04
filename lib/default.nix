{ lib, ... }:

with lib;

rec {
  mkEnableOptionTrue = a: mkEnableOption a // { default = true; };

  types = rec {
    keybindingStr = lib.types.str // {
      description = "A (neo)vi(m) keybinding string.";
    };

    # keymapping = with lib.types; attrsOf str;
    keymapping = lib.types.submodule {
      options = {
        action = mkOption {
          type = lib.types.str;
          description =
            "The action to be performed when this keybinding is activated.";
        };
        keys = mkOption {
          type = keybindingStr;
          description = "The keys to be pressed to activate this keybinding.";
        };
        mapCommand = mkOption {
          type = lib.types.enum [
            "nmap"
            "nnoremap"

            "vmap"
            "vnoremap"

            "map"
            "noremap"
          ];
          description = "Which (re)map command to use.";
          default = "nnoremap";
        };

        # TODO: proper options for figuring out which {,n,v,i,c,s,x,o,l}{,nore}map to use
        # remap = mkEnableOption "the remapping of keys defined as the action";
      };
    };
  };
}
