{ lib, ... }:

with lib;

rec {
  mkOptionEnableTrue = a: mkOptionEnable a // { default = true; };

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
  };
}
