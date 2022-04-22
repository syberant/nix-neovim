{
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/master"; };

  outputs = { self, nixpkgs }:

    with nixpkgs.lib;
    with builtins;

    let
      dpkgs = import nixpkgs {
        system = "x86_64-linux";
        config = { allowUnfree = true; };
      };

      # TODO: move these somewhere else
      getFiles = { dir, suffix ? null, allow_default ? true }:
        let
          hasDefault = d: hasAttr "default.nix" (readDir (dir + "/${d}"));
          isImportable = name: kind:
            if kind == "directory" then
              allow_default && hasDefault name
            else
              suffix == null || hasSuffix suffix name;
          files = attrNames (filterAttrs isImportable (readDir dir));
        in map (f: dir + "/${f}") files;
      getNixFiles = dir:
        getFiles {
          inherit dir;
          suffix = "nix";
        };

      buildNeovim = { pkgs ? dpkgs, configuration }:
        let
          eval = evalModules {
            modules = getNixFiles ./modules ++ [
              (rec {
                _file = ./flake.nix;
                key = _file;
                config = {
                  _module.args.pkgs = mkForce pkgs;
                  _module.args.vimLib = import ./lib { lib = pkgs.lib; };
                };
              })

              configuration
            ];
          };
        in eval.config.product.binary;
    in {
      description = "Declaratively configure neovim with the magic of nix!";

      inherit buildNeovim;

      # For nix build
      defaultPackage."x86_64-linux" =
        buildNeovim { configuration = ./test.nix; };

      # For nix run
      defaultApp."x86_64-linux" = {
        type = "app";
        program = "${self.defaultPackage."x86_64-linux"}/bin/nvim";
      };
    };
}
