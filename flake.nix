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

          # Reuse NixOS documentation generator
          # Use `customNeovim.passthru.documentation.optionsMDDoc` to get markdown documentation as a string
          # https://github.com/NixOS/nixpkgs/blob/8284fc30c84ea47e63209d1a892aca1dfcd6bdf3/nixos/lib/make-options-doc/default.nix#L153
          documentation = pkgs.nixosOptionsDoc {
            options = eval.options;
            revision = self.rev or "";
          };

          # Generate vim help file
          singleVimWiki = name: value:
            ''
              -------------------------------------------------------------------------------
              *${name}*
              ${value.description}

            '' + optionalString (value ? type) ''
              Type: >
                ${value.type}
              >
            '' + optionalString (value ? default) ''
              Default: >
                ${builtins.toJSON value.default}
              >
            '' + optionalString (value ? example) ''
              Example: >
                ${builtins.toJSON value.example}
              >
            '';
          optionsVimWiki = o:
            ''
              *nix-neovim-configuration.txt*

              ===============================================================================
              OPTIONS ~
              You can use the following options in your `configuration.nix` file.

            '' + concatStringsSep "\n" (mapAttrsToList singleVimWiki o);

          res = eval.config.output;
          rcfile = pkgs.writeText "nix-neovim-rc.vim" res.config_file;
        in pkgs.wrapNeovim res.package {
          extraMakeWrapperArgs = " " + res.makeWrapper;
          configure = {
            customRC = ''
              " Allows user to inspect the generated configuration with :NixNeovimRc
              command NixNeovimRc edit ${rcfile}

              source ${rcfile}
            '';

            packages.myVimPackage.start = res.plugins ++ [
              (pkgs.vimUtils.buildVimPluginFrom2Nix {
                name = "nix-neovim";
                src = pkgs.symlinkJoin {
                  name = "nix-neovim-plugin";
                  paths = [
                    ./plugin
                    (pkgs.writeTextDir "doc/nix-neovim-configuration.txt"
                      (optionsVimWiki documentation.optionsNix))
                  ];
                };
              })
            ];
          };
        } // {
          passthru.customRC = rcfile;
        };
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
