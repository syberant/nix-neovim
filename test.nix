{ pkgs, ... }:

{
  vim = {
    keybindings = {
      leader = " ";
      which-key-nvim = true;

      keybindings-shortened = {
        "<leader>;" = {
          command = "<Plug>NERDCommenterToggle";
          options.silent = true;
        };
      };
    };

    g.tokyonight_style = "storm";
    opt.showmode = false;
  };

  output = {
    path.style = "pure";
    plugins = with pkgs.vimPlugins; [ nerdcommenter vim-nix tokyonight-nvim ];
    extraConfig = ''
      colorscheme tokyonight
    '';
  };
}
