nix-neovim
==========

The goal of this project is to have a [NixOS](https://nixos.org)- and [home-manager](https://github.com/nix-community/home-manager)-like way to manage my neovim installation.
I will add stuff I use but it is completely extendible by everyone! You can easily use your own modules because I'm piggybacking off the NixOS module system.

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
```

Debugging
---------
`nix-neovim` provides some tools for helping you debug your neovim config:
- `:checkhealth nix_neovim` for a quick overview of your configuration
- `:NixNeovimRc` opens your generated vimrc
- `:help nix-neovim-configuration.txt` contains a complete list of options, similar to `man configuration.nix` for NixOS

Links
-----
- [vi-tality/neovitality](https://github.com/vi-tality/neovitality), another project aiming to configure neovim with Nix
- [pta2002/nixvim](https://github.com/pta2002/nixvim), also aiming to configure neovim with Nix, paused development but interesting nonetheless
- [Nixpkgs manual section on (neo)vim](https://nixos.org/manual/nixpkgs/stable/#vim), nix-neovim depends on this Nixpkgs functionality
- [nanotee/nvim-lua-guide](https://github.com/nanotee/nvim-lua-guide), guide to using lua for neovim configuration, used for writing much of the internals of nix-neovim
