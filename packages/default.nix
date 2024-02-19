{ lib, pkgs, ... }:
let
  sources = import ../npins;

  linux_x13s_pkg =
    { buildLinux, ... }@args:
    let
      version = "6.8.0-rc5";
      modDirVersion = "${version}";
    in
    buildLinux (
      args
      // {
        inherit version modDirVersion;

        src = sources.linux;

        kernelPatches = (args.kernelPatches or [ ]) ++ [
          {
            # fix resets when reading EFI vars
            name = "qcom-shm-bridge-tz";
            patch = (
              pkgs.fetchurl {
                url = "https://lore.kernel.org/lkml/20240205182810.58382-1-brgl@bgdev.pl/t.mbox.gz";
                hash = "sha256-kplvgUGE70eVivaN59Ozj7/utgnPEkVUjC8nemyM4vU=";
              }
            );
            extraStructuredConfig = {
              QCOM_TZMEM_MODE_SHMBRIDGE = lib.kernel.yes;
            };
          }
        ];
        extraMeta.branch = lib.versions.majorMinor version;
      }
    );
in
rec {
  "x13s/linux" = pkgs.callPackage linux_x13s_pkg { defconfig = "johan_defconfig"; };
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
