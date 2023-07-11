{
  config,
  fetchurl,
  lib,
  options,
  pkgs,
  ...
}: let
  inherit (config.boot.loader) efi;
  kp = [
    {
      name = "x13s-cfg";
      patch = null;
      extraStructuredConfig = with lib.kernel; {
        EFI_ARMSTUB_DTB_LOADER = lib.mkForce yes;
        OF_OVERLAY = lib.mkForce yes;
        MEDIA_CONTROLLER = lib.mkForce yes;
        SND_USB_AUDIO_USE_MEDIA_CONTROLLER = lib.mkForce yes;
        SND_USB = lib.mkForce yes;
        SND_USB_AUDIO = lib.mkForce module;
        USB_XHCI_PCI = lib.mkForce module;
        NO_HZ_FULL = lib.mkForce yes;
        HZ_100 = lib.mkForce yes;
        HZ_250 = lib.mkForce no;
        DRM_AMDGPU = lib.mkForce no;
        DRM_NOUVEAU = lib.mkForce no;
      };
    }
  ];

  # We can't quite move to mainline linux
  linux_x13s_pkg = { buildLinux, ... } @ args:
    buildLinux (args // rec {
      version = "6.4.2";
      modDirVersion = lib.versions.pad 3 version;
      extraMeta.branch = lib.versions.majorMinor version;

      src = pkgs.fetchFromGitHub {
        owner = "jhovold";
        repo = "linux";
        rev = "8552e6b238d8d7f2d0668d71e05a7998d889a7a0";
        hash = "sha256-ohb7e8MSkdmQzp6g+Ulsq7ylJ4CGAIGyqPLxvX0ZkSI=";
      };
      kernelPatches = (args.kernelPatches or [ ]) ++ kp;
    } // (args.argsOverride or { }));

  # we add additional configuration on top of te normal configuration above
  # using the extraStructuredConfig option on the kernel patch
  linux_x13s = pkgs.callPackage linux_x13s_pkg {
    defconfig = "defconfig";
  };

  uncompressed-fw = pkgs.callPackage
    ({ lib, runCommand, buildEnv, firmwareFilesList }:
      runCommand "qcom-modem-uncompressed-firmware-share"
        {
          firmwareFiles = buildEnv {
            name = "qcom-modem-uncompressed-firmware";
            paths = firmwareFilesList;
            pathsToLink = [
              "/lib/firmware/rmtfs"
              "/lib/firmware/qcom"
            ];
          };
        } ''
        PS4=" $ "
        (
        set -x
        mkdir -p $out/share/
        ln -s $firmwareFiles/lib/firmware/ $out/share/uncompressed-firmware
        )
      '')
    {
      firmwareFilesList = lib.flatten options.hardware.firmware.definitions;
    };

  linuxPackages_x13s = pkgs.linuxPackagesFor linux_x13s;
  dtb = "${linuxPackages_x13s.kernel}/dtbs/qcom/sc8280xp-lenovo-thinkpad-x13s.dtb";

  dtbName = "x13s63rc4.dtb";
in {
  boot = {
    loader.systemd-boot.enable = true;
    loader.systemd-boot.extraFiles = {
      "${dtbName}" = dtb;
    };
    loader.efi.canTouchEfiVariables = true;
    loader.efi.efiSysMountPoint = "/boot";

    kernelPackages = linuxPackages_x13s;

    kernelParams = [
      "boot.shell_on_fail"
      "clk_ignore_unused"
      "pd_ignore_unused"
      "arm64.nopauth"
      "cma=128M"
      "nvme.noacpi=1"
      "iommu.strict=0"
      "dtb=${dtbName}"
    ];
    initrd = {
      includeDefaultModules = false;
      availableKernelModules = [
        "i2c_hid"
        "i2c_hid_of"
        "i2c_qcom_geni"
        "leds_qcom_lpg"
        "pwm_bl"
        "qrtr"
        "pmic_glink_altmode"
        "gpio_sbu_mux"
        "phy_qcom_qmp_combo"
        "panel-edp"
        "msm"
        "phy_qcom_edp"
        "i2c-core"
        "i2c-hid"
        "i2c-hid-of"
        "i2c-qcom-geni"
        "pcie-qcom"
        "phy-qcom-qmp-combo"
        "phy-qcom-qmp-pcie"
        "phy-qcom-qmp-usb"
        "phy-qcom-snps-femto-v2"
        "phy-qcom-usb-hs"
        "nvme"
      ];
    };
  };

  # power management, etc.
  environment.systemPackages = with pkgs; [
    qrtr
    qmic
    rmtfs
    pd-mapper
    uncompressed-fw
  ];
  environment.pathsToLink = [ "share/uncompressed-firmware" ];

  # ensure the x13s' dtb file is in the boot partition
  system.activationScripts.x13s-dtb = ''
    in_package="${dtb}"
    esp_tool_folder="${efi.efiSysMountPoint}/"
    in_esp="''${esp_tool_folder}${dtbName}"
    >&2 echo "Ensuring $in_esp in EFI System Partition"
    if ! ${pkgs.diffutils}/bin/cmp --silent "$in_package" "$in_esp"; then
      >&2 echo "Copying $in_package -> $in_esp"
      mkdir -p "$esp_tool_folder"
      cp "$in_package" "$in_esp"
      sync
    fi
  '';

  hardware.enableAllFirmware = true;
  hardware.firmware = [pkgs.linux-firmware (pkgs.callPackage ./pkgs/x13s-firmware.nix {})];
}

