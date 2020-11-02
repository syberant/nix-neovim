{ lib, ... }:

with lib;

rec {
  mkEnableOptionTrue = a: mkEnableOption a // { default = true; };

  types = rec {
    # Allows defining [ bool a ], for use in optionalStringList
    opt = a:
      with lib.types;
      listOf a // {
        description =
          "shorthand notation for an optional ${a.description}, written as [ bool ${a.name} ] OR ${a.name}";
        check = def:
          a.check def || (isList def && length def == 2 && bool.check (head def)
            && a.check (head (tail def)));
      };

    optionalStringList = with lib.types;
      listOf (opt str) // {
        merge = let
          toOptList = map (a: if isList a then a else [ true a ]);
          optListToList = concatMap (a: optional (head a) (head (tail a)));
        in loc: defs: optListToList (toOptList (concatLists (getValues defs)));

        description = "A list whose elements are either [ bool str ] or str.";

        check = def: foldl' (acc: b: acc && (opt str).check b) true def;
      };

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
