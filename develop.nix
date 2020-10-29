{ pkgs ? import <nixpkgs> { }, configuration ? ./test.nix }:

import ./default.nix { inherit pkgs configuration; }
