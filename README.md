nix-neovim
==========

The goal of this project is to have a [NixOS](https://nixos.org)- and [home-manager](https://github.com/nix-community/home-manager)-like way to manage my neovim installation.
I will add stuff I use but it is completely extendible by everyone! You can split up your configuration into modules because I'm piggybacking off the NixOS module system.

Usage
-----
This project gives you a function that takes a `configuration` and `pkgs`, the example below illustrates how to use this in a NixOS module.
```nix
{ pkgs, ... }:

let source = builtins.fetchGit {
        url = "https://github.com/syberant/nix-neovim.git";
        rev = "36082ecb85d2dd66aaa47ecfe943ae5ec47012eb"; # Change this to a newer version
        sha256 = "0qpavrrqr65cddgfv5hpi4njhbg0lnf00b85nz0kmzi5rl2wv6ix"; # Change this to the appropriate hash
    };
    nix-neovim = import source;
    configuration = {
        languages.nix.enable = true;
        colourscheme.gruvbox.enable = true;
        lightline.enable = true;
    };
    # Or use a separate file for configuration
    # configuration = ./test.nix
in {
    environment.systemPackages = [ (nix-neovim { inherit configuration pkgs; }) ];
}
```

Or with flakes:
```bash
$ # Try out the ./test.nix configuration
$ nix run github:syberant/nix-neovim
$ # Or my personal configuration (warning: it has LARGE dependencies, LaTeX in particular.)
$ nix run github:syberant/nix-config#neovim
```

Philosophy
----------
Early on this project contained default configurations for many common plugins, each with relevant options.
This caused a great deal of pain as there was little distinction between `nix-neovim` and [my personal neovim config](https://github.com/syberant/nix-config/blob/master/configuration/home-manager/modules/neovim/configuration.nix) and constantly updating these options turned out to be very opinionated and problematic (trying to get them complete even more so).

My current goal for this project is to explicitly exclude configuration of specific plugins and instead only provide tools for managing neovim configuration with Nix.
This results in features like:
- `vim.opt` to set options (`set KEY=VALUE` in vimscript)
- `vim.g` to set global variables (`let g:KEY=VALUE` in vimscript)
- `vim.keybindings` to set keymappings (a hot mess in vimscript)
- Purity modes
- `plugin.setup` to handle the common pattern `require(KEY).setup(VALUE)` of lua plugins

Many of these features are accomplished by allowing users to define a Nix set and then generating an equivalent JSON file, lua code then reads that JSON file and does the appropriate configuration.
This allows splitting up your configuration into many small modules as these Nix sets are merged together like you expect.

Debugging
---------
`nix-neovim` provides some tools for helping you debug your neovim config:
- `:help nix-neovim-configuration.txt` contains a complete list of options, similar to `man configuration.nix` for NixOS
- `:checkhealth nix_neovim` for a quick overview of your configuration
- `:NixNeovimRc` opens your generated vimrc
- `:NixNeovimPlugins` opens the directory of your installed plugins
- Switching between purity modes (see `:h output.path.style`) can be done live:
    - `:NixNeovimPathPure` sets `$PATH` to only contain packages defined in `output.path.path`
    - `:NixNeovimPathImpure` prefixes `$PATH` with packages defined in `output.path.path`
    - `:NixNeovimPathNopath` resets `$PATH` to your own environment

Links
-----
- [vi-tality/neovitality](https://github.com/vi-tality/neovitality), another project aiming to configure neovim with Nix
- [pta2002/nixvim](https://github.com/pta2002/nixvim), also aiming to configure neovim with Nix, paused development but interesting nonetheless
- [Nixpkgs manual section on (neo)vim](https://nixos.org/manual/nixpkgs/stable/#vim), nix-neovim depends on this Nixpkgs functionality
- [nanotee/nvim-lua-guide](https://github.com/nanotee/nvim-lua-guide), guide to using lua for neovim configuration, used for writing much of the internals of nix-neovim
