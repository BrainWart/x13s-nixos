{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      nixosModules = {
        default = import ./module.nix;
      };
      forAllSystems =
        function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
        ] (system: function nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: {
        bios-update-utility = pkgs.callPackage ./packages/x13s/firmware/bios-update-utility.nix { };
        installer = (import ./configurations/iso.nix { inherit pkgs; }).config.system.build.isoImage;
      });
      devShells = forAllSystems (pkgs: {
        default = import ./shell.nix { inherit pkgs; };
      });
      legacyPackages = forAllSystems (pkgs: import ./default.nix { inherit pkgs; });
      inherit nixosModules;
    };
}
