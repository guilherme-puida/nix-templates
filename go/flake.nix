{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, gomod2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ gomod2nix.overlays.default ];
        };

        everything = pkgs.buildGoApplication {
          name = "everything";
          src = ./.;
          modules = ./gomod2nix.toml;
        };

        template = pkgs.buildGoApplication {
          name = "server";
          src = ./.;
          modules = ./gomod2nix.toml;
          subPackages = [ "cmd/template" ];
        };
      in
      {
        packages = {
          default = everything;
          inherit template;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            gopls
            go-tools

            gomod2nix.packages.${system}.default
          ];
        };
      });
}
