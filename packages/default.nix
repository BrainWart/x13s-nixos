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
    version = "6.8.0-rc5";
    defconfig = "johan_defconfig";
  };

  linux_steev = pkgs.callPackage linux_x13s_pkg {
    src = sources.linux-steev;
    version = "6.7.5";
    defconfig = "laptop_defconfig";
  };

  "x13s/alsa-ucm-conf" = pkgs.alsa-ucm-conf.overrideAttrs (
    _: {
      version = sources.alsa-ucm-conf.version;
      src = sources.alsa-ucm-conf;
      patches = [ ];
    }
  );

  pd-mapper = pkgs.callPackage ./pd-mapper { inherit qrtr; };
  qrtr = pkgs.callPackage ./qrtr { };

  "x13s/extra-firmware" = pkgs.callPackage ./extra-firmware.nix { };
}
