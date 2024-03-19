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
  linux_jhovold = linux_jhovold_6_8;

  linux_jhovold_6_8 = pkgs.callPackage linux_x13s_pkg {
    src = sources.linux-jhovold;
    version = "6.8.0";
    defconfig = "johan_defconfig";
  };

  linux_steev = pkgs.callPackage linux_x13s_pkg {
    src = sources.linux-steev;
    version = "6.8.1";
    defconfig = "laptop_defconfig";

    # fix build using extra config from
    # https://github.com/boletus-edulis/hydra-test/blob/fffbd42c511e7384be76dc88ea246bc7064d7b49/pkgs/linux_x13s.nix
    structuredExtraConfig = with lib.kernel; {
      VIDEO_AR1337 = no;
      AUDIT = yes;
      ARM64_SME = yes;
      MAC80211_LEDS = yes;
      FW_LOADER_USER_HELPER = yes;
      QCOM_EBI2 = yes;
      EFI_CAPSULE_LOADER = yes;
      SRAM = yes;
      KEYBOARD_GPIO = yes;
      SERIAL_QCOM_GENI = yes;
      PINCTRL_QCOM_SPMI_PMIC = yes;
      PINCTRL_SC8280XP_LPASS_LPI = module;
      QCOM_TSENS = yes;
      BACKLIGHT_CLASS_DEVICE = yes;
      VIRTIO_MENU = yes;
      VHOST_MENU = yes;
      SC_GCC_8280XP = yes;
      SC_GPUCC_8280XP = yes;
      QCOM_Q6V5_ADSP = module;
      QCOM_STATS = yes;
      QCOM_CPR = yes;
      QCOM_RPMHPD = yes;
      QCOM_RPMPD = yes;
      PHY_QCOM_QMP_PCIE_8996 = yes;
      NVMEM_QCOM_QFPROM = yes;
      CRYPTO_AES_ARM64_CE_BLK = yes;
      CRYPTO_AES_ARM64_BS = yes;
      CRYPTO_AES_ARM64_CE_CCM = yes;
      CONFIG_CRYPTO_DEV_CCREE = module;
    };
  };

  pd-mapper = pkgs.callPackage ./pd-mapper { inherit qrtr; };
  qrtr = pkgs.callPackage ./qrtr { };

  "x13s/extra-firmware" = pkgs.callPackage ./extra-firmware.nix { };
}
