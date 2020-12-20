{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";

    neovim-nightly.url = "github:mjlbach/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, neovim-nightly }:

    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config = { allowUnfree = true; };
        overlays = [ neovim-nightly.overlay ];
      };
    in rec {
      fromConfig = configuration:
        import ./default.nix { inherit pkgs configuration; };

      defaultPackage."x86_64-linux" = fromConfig ./test.nix;
    };
}
