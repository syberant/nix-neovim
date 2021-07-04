{ configuration, pkgs }:

with pkgs.lib;
with builtins;

let
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
  modules = getNixFiles ./modules;

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
