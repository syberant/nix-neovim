{ pkgs, ... }:

{
  # colourscheme.gruvbox.enable = true;
  colourscheme.tokyonight.enable = true;
  colourscheme.tokyonight.style = "night";
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

  # vim-tmux-navigator.enable = true;

  base = {
    search.enable = true;
    wrapping.enable = true;
    files.enable = true;

    keybindings = {
      leader = "\\<space>";
      keybindings-shortened."<leader>;" = {
        command = "<Plug>NERDCommenterToggle";
        options.silent = true;
      };
    };
  };

  output.path.style = "pure";

  output.extraConfig = ''
    " set timeoutlen=500
  '';
}
