{ pkgs, ... }:

{
  colourscheme.gruvbox.enable = true;
  languages = {
    nix.enable = true;
    haskell.enable = true;
    rust.enable = true;
  };
  neoformat.enable = true;
  lightline.enable = true;
  nerdcommenter.enable = true;
  gitgutter.enable = true;
  vim-surround.enable = true;
  vim-which-key = {
    enable = true;
    showkeys = [ "<Space>" ];
  };

  base = {
    leader = "\\<space>";
    search.enable = true;
    wrapping.enable = true;
    files.enable = true;

    keybindings = [{
      action = "<Plug>NERDCommenterToggle";
      keys = "<leader>;";
      mapCommand = "map";
    }];
    set = [ "nowrap" ];
  };

  output.package = pkgs.neovim-nightly;
  output.enableDevConfig = true;

  output.extraConfig = ''
    " map <leader>; <Plug>NERDCommenterToggle
    " set timeoutlen=500
  '';
}
