{ lib, pkgs, ... }:
let
  sources = import ../npins;

  linux_x13s_pkg =
    { buildLinux, ... }@args:
    let
      version = "6.8.0-rc1";
      modDirVersion = "${version}";
    in
    buildLinux (
      args
      // {
        inherit version modDirVersion;

        src = sources.linux;

        kernelPatches = args.kernelPatches or [ ];
        extraMeta.branch = lib.versions.majorMinor version;
      }
    );
in
rec {
  "x13s/linux" = pkgs.callPackage linux_x13s_pkg { defconfig = "johan_defconfig"; };
  "x13s/alsa-ucm-conf" = pkgs.alsa-ucm-conf.overrideAttrs (
    prev: rec {
      version = "1.2.11-unstable-${builtins.substring 0 7 src.revision}";
      src = sources.alsa-ucm-conf;
    }
  );

  pd-mapper = pkgs.callPackage ./pd-mapper { inherit qrtr; };
  qrtr = pkgs.callPackage ./qrtr { };

  "x13s/extra-firmware" = pkgs.callPackage ./extra-firmware.nix { };
}
