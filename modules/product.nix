{ pkgs, config, options, ... }:

with pkgs.lib;

let cfg = config.output;
in {
  options.product = {
    binary = mkOption {
      type = types.package;
      readOnly = true;
      description = ''
        The final product, a wrapped neovim binary containing all of the configuration you set.
        Its only purpose is to get the built binary out of the module system.
      '';
    };
  };

  config = {
    product.binary = let
      # Reuse NixOS documentation generator
      # Use `customNeovim.passthru.documentation.optionsMDDoc` to get markdown documentation as a string
      # https://github.com/NixOS/nixpkgs/blob/8284fc30c84ea47e63209d1a892aca1dfcd6bdf3/nixos/lib/make-options-doc/default.nix#L153
      documentation = pkgs.nixosOptionsDoc {
        options = options // { _module = { }; }; # All defined options
        # revision = self.rev or "";
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
        '' + optionalString (value ? readOnly) ''
          Read-only option, can not be changed but only read!
        '';
      optionsVimWiki = o:
        concatStringsSep "\n" (mapAttrsToList singleVimWiki o);

      rcfile = pkgs.writeText "nix-neovim-rc.vim" cfg.config_file;
    in pkgs.wrapNeovim cfg.package {
      extraMakeWrapperArgs = " " + cfg.makeWrapper;
      configure = {
        customRC = ''
          " Allows user to inspect the generated configuration with :NixNeovimRc
          command NixNeovimRc edit ${rcfile}

          source ${rcfile}
        '';

        packages.myVimPackage.start = cfg.plugins ++ [
          (pkgs.vimUtils.buildVimPluginFrom2Nix {
            name = "nix-neovim";
            src = pkgs.symlinkJoin {
              name = "nix-neovim-plugin";
              paths = [
                ../plugin
                (pkgs.writeTextDir "doc/nix-neovim-configuration.txt" ''
                  *nix-neovim-configuration.txt*

                  ===============================================================================
                  OPTIONS ~
                  You can use the following options in your `configuration.nix` file.

                  ${optionsVimWiki documentation.optionsNix}
                '')
              ];
            };
          })
        ];
      };
    } // {
      passthru = {
        customRC = rcfile;
        inherit documentation;
      };
    };
  };
}
