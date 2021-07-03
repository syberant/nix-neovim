{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
  };

  outputs = { self, nixpkgs }:

    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config = { allowUnfree = true; };
      };
    in rec {
      description = "Declaratively configure neovim with the magic of nix!";

      fromConfig = configuration:
        import ./default.nix { inherit pkgs configuration; };

      # For nix build
      defaultPackage."x86_64-linux" = fromConfig ./test.nix;

      # For nix run
      defaultApp."x86_64-linux" = {
        type = "app";
        program = "${self.defaultPackage."x86_64-linux"}/bin/nvim";
      };
    };
}
