{ configuration, pkgs }:

with pkgs.lib;

let
  modules = import ./modules/module-list.nix;
  pkgsModule = rec {
    _file = ./neovim.nix;
    key = _file;
    config = {
      _module.args.pkgs = mkForce pkgs;
      _module.args.vimLib = import ./lib { lib = pkgs.lib; };
    };
  };
  res = (evalModules {
    modules = modules ++ [ pkgsModule configuration ];
  }).config.output;
in pkgs.wrapNeovim res.package {
  extraMakeWrapperArgs = res.makeWrapper;
  configure = {
    customRC = res.config_file;
    packages.myVimPackage.start = res.plugins;
  };
}
