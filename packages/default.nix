{ lib, pkgs, ... }:
let
  sources = import ../npins;
  kp = [
    {
      name = "x13s-cfg";
      patch = null;
      extraStructuredConfig = with lib.kernel; {
        EFI_ARMSTUB_DTB_LOADER = lib.mkForce yes;
        OF_OVERLAY = lib.mkForce yes;
        BTRFS_FS = lib.mkForce yes;
        BTRFS_FS_POSIX_ACL = lib.mkForce yes;
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
        QCOM_TSENS = lib.mkForce yes;
        NVMEM_QCOM_QFPROM = lib.mkForce yes;
        ARM_QCOM_CPUFREQ_NVMEM = lib.mkForce yes;
        VIRTIO_PCI = lib.mkForce module;
        # forthcoming kernel work: QCOM_PD_MAPPER = lib.mkForce module;
      };
    }
  ];

  linux_x13s_pkg =
    { buildLinux, ... }@args:
    let
      version = "6.7.0";
      modDirVersion = "${version}";
    in
    buildLinux (
      args
      // {
        inherit version modDirVersion;

        src = sources.jhovold-linux;

        kernelPatches = (args.kernelPatches or [ ]) ++ kp;
        extraMeta.branch = lib.versions.majorMinor version;
      }
      // (args.argsOverride or { })
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
