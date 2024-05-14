{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, self, ... }:
    let
      dtbName = "sc8280xp-lenovo-thinkpad-x13s.dtb";
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ./packages/part.nix ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        { pkgs, ... }:
        {
          devShells = {
            default = pkgs.mkShellNoCC { packages = [ pkgs.npins ]; };
            ci = pkgs.mkShellNoCC { packages = [ pkgs.cachix ]; };
          };

          packages = {
            iso = self.nixosConfigurations.iso.config.system.build.isoImage;
          };
        };

      flake.nixosModules.default = import ./module.nix { inherit dtbName; };

      flake.nixosConfigurations = {
        example = inputs.nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            self.nixosModules.default
            {
              nixos-x13s.enable = true;
              nixos-x13s.kernel = "jhovold"; # jhovold is default, but mainline supported

              # install multiple kernels! note this increases eval time for each specialization
              # specialisation = {
              #   mainline.configuration.nixos-x13s.kernel = "mainline";
              # };

              # allow unfree firmware
              nixpkgs.config.allowUnfree = true;

              # define your fileSystems
              fileSystems."/".device = "/dev/notreal";
            }
          ];
        };

        iso = inputs.nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [

            self.nixosModules.default
            (
              { modulesPath, config, ... }:
              let
                dtb = "${config.boot.kernelPackages.kernel}/dtbs/qcom/${dtbName}";
              in
              {
                imports = [ "${toString modulesPath}/installer/cd-dvd/iso-image.nix" ];

                nixpkgs.config.allowUnfree = true;
                nixos-x13s.enable = true;
                isoImage = {
                  makeEfiBootable = true;
                  makeUsbBootable = true;

                  contents = [
                    {
                      source = dtb;
                      target = "/x13s.dtb";
                    }
                  ];
                };
              }
            )
          ];
        };
      };
    };
}
