{ configuration, pkgs }:

with pkgs.lib;

let
  modules = import ./modules/module-list.nix;
  pkgsModule = rec {
    _file = ./neovim.nix;
    key = _file;
    config = {
      _module.args.pkgs = mkForce pkgs;
      _module.args.vimLib =
        pkgs.lib.extend (self: super: import ./lib { lib = super; });
    };
  };
  res = (evalModules {
    modules = modules ++ [ pkgsModule configuration ];
  }).config.output;
in pkgs.neovim.override {
  configure = {
    customRC = res.config_file;
    packages.myVimPackage.start = res.plugins;
  };
}
