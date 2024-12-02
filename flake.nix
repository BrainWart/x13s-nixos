{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    systems.url = "github:nix-systems/default-linux";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs =
    { nixpkgs, flake-utils, ... }@inputs:
    let
      nixosConfigurations =
        let
          inherit (builtins)
            listToAttrs
            map
            readDir
            elemAt
            filter
            getAttr
            match
            attrNames
            ;
        in
        listToAttrs (
          map
            (config: {
              name = config;
              value = nixpkgs.lib.nixosSystem {
                system = "aarch64-linux";
                specialArgs = {
                  inherit inputs;
                };
                modules = [
                  inputs.self.nixosModules.aarch64-linux.default
                  (import (./configurations + "/${config}.nix"))
                ];
              };
            })
            (
              let
                entries = readDir ./configurations;
              in
              map (key: elemAt (match "(.+)\\.nix" (baseNameOf key)) 0) (
                filter (key: (getAttr key entries) == "regular") (attrNames entries)
              )
            )
        );
    in
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in
      {
        devShells.default = import ./shell.nix { inherit pkgs; };

        nixosModules.default = import ./module.nix;

        packages = import ./default.nix { inherit pkgs; };
      }
    ))
    // {
      inherit nixosConfigurations;
    };
}
