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
{
  linux_jhovold = pkgs.callPackage linux_x13s_pkg {
    src = sources.linux-jhovold;
    version = "6.11.0-rc1";
    defconfig = "johan_defconfig";
  };

  graphics-firmware =
    let
      gpu-src = pkgs.fetchurl {
        url = "https://download.lenovo.com/pccbbs/mobiles/n3hdr20w.exe";
        hash = "sha256-Jwyl9uKOnjpwfHd+VaGHjYs9x8cUuRdFCERuXqaJwEY=";
      };
    in
    pkgs.runCommand "graphics-firmware" { } ''
      mkdir -vp "$out/lib/firmware/qcom/sc8280xp/LENOVO/21BX"
      ${lib.getExe pkgs.innoextract} ${gpu-src}
      cp -v code\$GetExtractPath\$/*/*.mbn "$out/lib/firmware/qcom/sc8280xp/LENOVO/21BX/"
    '';
}
