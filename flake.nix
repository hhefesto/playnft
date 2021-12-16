{
  description = "playNFT flake";
  nixConfig.bash-prompt-suffix = "\\033[1;33m(playNFT)\\033[0m ";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.05";
    nixops.url = "github:input-output-hk/nixops-flake";
    utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self
            , nixpkgs
            , nixops
            , utils
            , flake-compat
            , ...
            } :
    let
      domain = "playnft.hhefesto.com";
      pkgsFor = system: import nixpkgs {
        inherit system;
        overlays = [self.overlay];
      };

    in {
      overlay = final: prev: {
        react-frontend = prev.callPackage ./react {};
	      eth-contracts = prev.callPackage ./eth {};
        elm-frontend = prev.callPackage ./elm {};
        js-backend =  prev.callPackage ./eth {};
      };
    } // utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let pkgs = pkgsFor system;
      in {
        defaultPackage = pkgs.eth-contracts;
        packages.playNFT-frontend = pkgs.elm-frontend;
        packages.playNFT-backend = pkgs.js-backend;

        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.nixops
            pkgs.elmPackages.elm
            pkgs.elmPackages.elm-live
            pkgs.elmPackages.create-elm-app
            pkgs.elm2nix
            pkgs.yarn
            pkgs.yarn2nix
            pkgs.nodejs
          ];
        };
      });
}
