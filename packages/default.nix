{ lib, pkgs, ... }:
let
  sources = import ../npins;

  linux_x13s_pkg =
    { version, buildLinux, ... }@args:
    buildLinux (
      args
      // {
        modDirVersion = version;

        kernelPatches = (args.kernelPatches or [ ]) ++ [ ];
        extraMeta.branch = lib.versions.majorMinor version;
      }
    );
in
rec {
  linux_jhovold = pkgs.callPackage linux_x13s_pkg {
    src = sources.linux-jhovold;
    version = "6.11.0-rc1";
    defconfig = "johan_defconfig";
  };

  pd-mapper = pkgs.callPackage ./pd-mapper { inherit qrtr; };
  qrtr = pkgs.callPackage ./qrtr { };

  "x13s/extra-firmware" = pkgs.callPackage ./extra-firmware.nix { };

  uncompressed-firmware = pkgs.callPackage ./uncompressed-firmware.nix { };
}
