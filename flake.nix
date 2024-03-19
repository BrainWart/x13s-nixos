{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ./packages/part.nix ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        { pkgs, ... }:
        {
          devShells.default = pkgs.mkShellNoCC { packages = [ pkgs.npins ]; };
        };

      flake.nixosModules.default = import ./module.nix;

      flake.nixosConfigurations.example = inputs.nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          self.nixosModules.default
          {
            nixos-x13s.enable = true;
            nixos-x13s.kernel = "jhovold"; # jhovold is default, but mainline supported

            # install multiple kernels! note this increases eval time for each specialization
            specialisation = {
              mainline.configuration.nixos-x13s.kernel = "mainline";
            };

            # allow unfree firmware
            nixpkgs.config.allowUnfree = true;

            # define your fileSystems
            fileSystems."/".device = "/dev/notreal";
          }
        ];
      };
    };
}
