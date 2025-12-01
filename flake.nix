{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    stable-nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    systems.url = "github:nix-systems/default-linux";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      stable-nixpkgs,
      ...
    }@inputs:
    let
      nixosModules = {
        default = import ./module.nix { inherit inputs; };
      };
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
        inherit nixosModules;

        devShells.default = import ./shell.nix { inherit pkgs; };

        packages = import ./default.nix { inherit pkgs; };
      }
    ))
    // {
      inherit nixosConfigurations nixosModules;
    };
}
