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

  "x13s/extra-firmware" = pkgs.callPackage ./extra-firmware.nix { };
}
