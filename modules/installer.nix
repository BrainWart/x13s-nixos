{
  modulesPath,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
    ../../module.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";
  system.stateVersion = "25.11";

  nixos-x13s.enable = true;
  nixos-x13s.kernel = null; # suppress warning

  nix.extraOptions = "experimental-features = nix-command flakes";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # we need this to show battery and enable sound in the live
  # image. This is module is blacklisted for boot because it
  # will cause the usb devices to be lost.
  systemd.services.bluetooth-remoteproc = {
    wantedBy = [ "multi-user.target" ];

    script = ''
      ${pkgs.kmod}/bin/modprobe qcom_q6v5_pas
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  boot = {
    supportedFilesystems.zfs = pkgs.lib.mkForce false;

    kernelParams = [
      "modprobe.blacklist=qcom_q6v5_pas"
    ];

    initrd = {
      extraFirmwarePaths = [
        "qca/hpbtfw21.tlv"
        "qca/hpnv21.bin"
        "qcom/sc8280xp/LENOVO/21BX/adspr.jsn"
        "qcom/sc8280xp/LENOVO/21BX/adspua.jsn"
        "qcom/sc8280xp/LENOVO/21BX/cdspr.jsn"
        "qcom/sc8280xp/LENOVO/21BX/qcslpi8280.mbn"
      ];

      availableKernelModules = [
        "pcieport"
        "mhi-pci-generic"
        "xhci-hcp"
        "usb-storage"
        "vfat"
      ];

      kernelModules = [
        "nvme"
        "phy-qcom-qmp-pcie"
        "pcie-qcom"

        "i2c-core"
        "i2c-hid"
        "i2c-hid-of"
        "i2c-qcom-geni"

        "leds_qcom_lpg"
        "pwm_bl"
        "qrtr"
        "pmic_glink_altmode"
        "gpio_sbu_mux"
        "phy-qcom-qmp-combo"
        "gpucc_sc8280xp"
        "dispcc_sc8280xp"
        "phy_qcom_edp"
        "panel-edp"
        "msm"
      ];
    };
  };

  isoImage = {
    makeEfiBootable = true;
    makeUsbBootable = true;
    contents = [
      {

        source = pkgs.writeText "grub.cfg" ''
          set timeout=10

          clear
          # This message will only be viewable on the default (UEFI) console.
          echo ""
          echo "Loading graphical boot menu..."
          echo ""
          echo "Press 't' to use the text boot menu on this console..."
          echo ""

          search --set=root --file /EFI/nixos-installer-image

          insmod gfxterm
          insmod png
          set gfxpayload=keep
          set gfxmode=1920x1200,1920x1080,1366x768,1280x800,1280x720,1200x1920,1024x768,800x1280,800x600,auto

          terminal_output gfxterm
          terminal_input  console

          set theme=($root)/EFI/BOOT/grub-theme/theme.txt
          loadfont ($root)/EFI/BOOT/grub-theme/dejavu.pf2

          if [ ''\${iso_path} ] ; then
            set isoboot="findiso=''\${iso_path}"
          fi

          #
          # Menu entries
          #

          menuentry 'NixOS 26.05.20260120.80e4adb Installer' --class installer {
            # Fallback to UEFI console for boot, efifb sometimes has difficulties.
            terminal_output console

            linux /boot${
              config.system.build.kernel + "/" + config.system.boot.loader.kernelFile
            } ''\${isoboot} init=${config.system.build.toplevel}/init ${toString config.boot.kernelParams} copytoram
            initrd /boot${config.system.build.initialRamdisk + "/" + config.system.boot.loader.initrdFile}
            devicetree /dtbs/${config.boot.kernelPackages.kernel.version}/${config.hardware.deviceTree.name}
          }
        '';
        target = "/EFI/BOOT/grub.cfg";
      }
    ]

    ++ lib.optionals (!config.boot.loader.grub.enable && !config.boot.loader.systemd-boot.enable) [
      {
        source = config.hardware.deviceTree.package;
        target = "/dtbs/${config.boot.kernelPackages.kernel.version}";
      }
    ]

    ++ (lib.optionals config.boot.loader.grub.enable (
      builtins.map (source: {
        inherit source;
        target = config.boot.loader.grub.extraFiles.${source};
      }) (builtins.attrNames config.loader.boot.grub.extraFiles)
    ))

    ++ (lib.optionals config.boot.loader.systemd-boot.enable (
      builtins.map (target: {
        inherit target;
        source = config.boot.loader.systemd-boot.extraFiles.${target};
      }) (builtins.attrNames config.boot.loader.systemd-boot.extraFiles)
    ));
  };
}
