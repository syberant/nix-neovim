{ pkgs ? import <nixpkgs> { }, configuration ? ./test.nix }:

import ./neovim.nix { inherit pkgs configuration; }
