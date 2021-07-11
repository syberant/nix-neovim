{ pkgs, config, ... }:

with pkgs.lib;

let cfg = config.output;
in {
  options.output = {
    config_file = mkOption {
      type = types.lines;
      default = "";
      description =
        "Raw text ending up in config file, this is used internally by all modules, please use extraConfig instead to place your extra configuration after nix-neovim's automated one.";
    };

    plugins = mkOption {
      type = with types; listOf package;
      default = [ ];
      description = "Escape hatch for extra plugins.";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Escape hatch for extra configuration.";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.neovim-unwrapped;
      description = "Unwrapped neovim binary.";
    };

    path = {
      style = mkOption {
        type = types.enum [ "pure" "impure" "nopath" ];
        default = "impure";
        description = ''
          Decides the style in which neovim's PATH is altered.

          pure: Neovim's PATH is overwritten meaning that it can NOT access the binaries in your own PATH.
          impure: The necessary dependencies will be added (prefixed) to neovim's PATH but binaries in your own PATH will work as fallback.
          nopath: PATH is not altered. Disables many of nix-neovim's dependencies significantly reducing closure size, you will have to make sure you provide these dependencies yourself.
        '';
      };

      path = mkOption {
        type = with types; listOf package;
        default = [ ];
        description =
          "PATH available to neovim, `output.pure` determines whether this complements your PATH or replaces it.";
        example = ''
          output.path = with pkgs; makeBinPath pkgs.stdenv.initialPath;
        '';
      };
    };

    makeWrapper = mkOption {
      type = types.separatedString " \\\n";
      default = "";
      description = "Args to pass to the makeWrapper command.";
      example = ''
        output.makeWrapper = with pkgs; "--set PATH ''${
          makeBinPath [ coreutils gnused gawk gnugrep ]
        }";
      '';
    };
  };

  config = {
    output.config_file = mkAfter cfg.extraConfig;

    # Add a base set of utilities (sh, awk, sed, etc.)
    output.path.path = pkgs.stdenv.initialPath;

    vim.g.nix_neovim_path = if cfg.path.style == "nopath" then
      "nopath"
    else
      pkgs.symlinkJoin {
        name = "nix-neovim-PATH";
        paths = cfg.path.path;
      } + "/bin";
    vim.g.nix_neovim_current_style = cfg.path.style;
  };
}
