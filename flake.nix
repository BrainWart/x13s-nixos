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
          devShells = rec {
            default = pkgs.mkShellNoCC { packages = [ pkgs.npins ] ++ ci.nativeBuildInputs; };

            ci = pkgs.mkShellNoCC {
              packages = [
                pkgs.cachix
                pkgs.jq
                pkgs.just
                (pkgs.python3.withPackages (py: [
                  py.PyGithub
                  py.packaging
                ]))
                pkgs.pyright
              ];
            };
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
            (
              { config, pkgs, ... }:
              {
                nixos-x13s.enable = true;
                nixos-x13s.kernel = "jhovold"; # jhovold is default, but mainline supported

                # allow unfree firmware
                nixpkgs.config.allowUnfree = true;

                # define your fileSystems
                fileSystems."/".device = "/dev/notreal";
              }
            )
          ];
        };

        iso = inputs.nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [

            self.nixosModules.default
            (
              {
                modulesPath,
                config,
                lib,
                pkgs,
                ...
              }:
              let
                dtb = "${config.boot.kernelPackages.kernel}/dtbs/qcom/${dtbName}";
                image = import "${inputs.nixpkgs}/nixos/lib/make-disk-image.nix" {
                  inherit config lib pkgs;

                  name = "nixos-x13s-bootstrap";
                  diskSize = "auto";
                  format = "raw";
                  partitionTableType = "efi";
                  copyChannel = false;
                };

              in
              {
                imports = [ "${toString modulesPath}/installer/cd-dvd/iso-image.nix" ];

                hardware.deviceTree = {
                  enable = true;
                  name = "qcom/${dtbName}";
                };

                system.build.bootstrap-image = image;

                boot.initrd.systemd.enable = true;
                boot.initrd.systemd.emergencyAccess = true;
                boot.loader.grub.enable = false;
                boot.loader.systemd-boot.enable = true;
                boot.loader.systemd-boot.graceful = true;

                nixpkgs.config.allowUnfree = true;

                nixos-x13s = {
                  enable = true;
                  bluetoothMac = "02:68:b3:29:da:98";
                };

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
