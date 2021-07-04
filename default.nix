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

  rcfile = pkgs.writeText "nix-neovim-rc.vim" res.config_file;
in pkgs.wrapNeovim res.package {
  extraMakeWrapperArgs = " " + res.makeWrapper
    + " --set NIXNEOVIMRC '${rcfile}'";
  configure = {
    customRC = "source ${rcfile}";

    packages.myVimPackage.start = res.plugins;
  };
} // {
  passthru.customRC = rcfile;
}
