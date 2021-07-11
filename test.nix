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
  nerdcommenter.enable = true;

  vim = {
    keybindings = {
      leader = " ";
      which-key-nvim = true;

      keybindings."<leader>" = {
        ";" = {
          command = "<Plug>NERDCommenterToggle";
          options.silent = true;
        };
      };
    };
  };

  output.path.style = "pure";

  output.extraConfig = ''
    " set timeoutlen=500
  '';
}
