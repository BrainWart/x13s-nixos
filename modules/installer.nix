{
  modulesPath,
  pkgs,
  lib,
  config,
  ...
}:
{
  disabledModules = [
    "${modulesPath}/installer/scan/detected.nix"
    "${modulesPath}/installer/scan/not-detected.nix"
  ];

  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
    ../module.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";
  system.stateVersion = "25.11";

  nixos-x13s.enable = true;
  nixos-x13s.kernel = null; # suppress warning

  virtualisation.hypervGuest.enable = lib.mkForce false;

  nix.extraOptions = "experimental-features = nix-command flakes";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # we need this to show battery and enable sound in the live
  # image. This is module is blacklisted for boot because it
  # will cause the usb devices to be lost.
  systemd.services.start-qcom_q6v5_pas = {
    wantedBy = [ "multi-user.target" ];

    script = ''
      if (cat /proc/cmdline | grep --silent 'copytoram') ; then
        echo 'system configured to copy to ram. temporarily losing USB should be fine.'
        ${pkgs.kmod}/bin/modprobe qcom_q6v5_pas
      else
        echo 'temporarily losing USB looks fatal'
        exit 1
      fi
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
        "qcom/sc8280xp/LENOVO/21BX/qcadsp8280.mbn"
        "qcom/sc8280xp/LENOVO/21BX/qccdsp8280.mbn"
        "qcom/sc8280xp/LENOVO/21BX/qcslpi8280.mbn"
        "qcom/sc8280xp/LENOVO/21BX/qcdxkmsuc8280.mbn"
        "qcom/sc8280xp/LENOVO/21BX/qcvss8280.mbn"
      ];

      availableKernelModules = [
        # "adreno"
        # "aer"
        # "alarmtimer"
        # "arch-timer-mmio"
        "arm-smmu"
        # "armv8-pmu"
        "aux_bridge"
        "aux_hpd_bridge"
        # "bcm_voter"
        "camcc-sc8280xp"
        "clk-rpmh"
        "cmd-db"
        # "ctrl"
        "dispcc-sc8280xp" # "disp_cc-sc8280xp"
        "dummy"
        "dwc3"
        "dwc3-qcom-legacy"
        # "faux_driver"
        "gcc-sc8280xp"
        "i2c-qcom-geni" # "geni_i2c"
        # "geni_se_qup"
        # "genpd_provider"
        "gpi"
        "gpio-keys"
        "gpio_sbu_mux"
        "gpucc-sc8280xp" # "gpu_cc-sc8280xp"
        "hci_uart" # "hci_uart_qca"
        # "hdmi-audio-codec"
        "hid-generic"
        "hid-multitouch"
        # "hub"
        "i2c_hid_of"
        "i2c-qcom-cci"
        "leds-gpio"
        "lpasscc-sc8280xp"
        "mhi-pci-generic"
        "mhi_wwan_ctrl"
        "mhi_wwan_mbim"
        # "msm-dp-display"
        # "msm_dpu"
        # "msm-mdss"
        "nvme"
        "icc-osm-l3" # "osm-l3"
        "ov5675"
        # "panel-simple-dp-aux"
        # "pcie_pme"
        # "pcieport"
        "pci-pwrctrl-pwrseq"
        "qcom-pm8008" # "pm8008"
        "pm8941-pwrkey"
        "pmic_glink_altmode"
        # "pmic-spmi"
        # "pmic_glink_power_supply"
        # "port"
        # "psci-cpuidle-domain"
        # "pwm-backlight"
        "pwrseq-qcom_wcn"
        # "qcom,qfprom"
        # "qcom_aoss_qmp"
        "qcom_battmgr"
        # "qcom-bwmon"
        "qcom-camss"
        "qcom-cpufreq-hw"
        "phy-qcom-edp" # "qcom-edp-phy"
        "qcom_geni_serial"
        "qcom_hwspinlock"
        "qcom-ipcc"
        "llcc-qcom" # "qcom-llcc"
        # "qcom_llcc_edac"
        # "qcom-pcie"
        "qcom_pdc"
        "qcom-pm8008-regulator"
        # "qcom_pmic_glink"
        "qcom-pon"
        "phy-qcom-qmp-combo" # "qcom-qmp-combo-phy"
        "phy-qcom-qmp-pcie" # "qcom-qmp-pcie-phy"
        "phy-qcom-qmp-usb" # "qcom-qmp-usb-phy"
        "qcom_qseecom"
        "qcom_qseecom_uefisecapp"
        "qcom_rng"
        # "qcom-rpmhpd"
        "qcom-rpmh-regulator"
        "qcom_scm"
        # "qcom-smem"
        # "qcom_smp2p"
        "phy-qcom-snps-femto-v2" # "qcom-snps-hs-femto-v2-phy"
        "socinfo" # "qcom-socinfo"
        "qcom-spmi-adc5"
        "qcom-spmi-adc-tm5"
        # "qcom-spmi-gpio"
        # "qcom-spmi-lpg"
        "qcom_stats"
        "qcomtee"
        "qcom-tsens"
        "qcom_wdt"
        "qnoc-sc8280xp"
        # "reg-fixed-voltage"
        # "rpmh"
        "rtc-pm8xxx"
        # "sc8280xp-tlmm"
        # "sd"
        # "serial8250"
        # "simple-pm-bus"
        "spmi_pmic_arb"
        "qcom-spmi-temp-alarm" # "spmi-temp-alarm"
        "ucsi_glink" # "ucsi_glink.pmic_glink_ucsi"
        # "usb"
        "usb-storage"
        # "wcd938x_codec"
        "wwan"
        "xhci-hcd"
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
      {
        source = config.hardware.deviceTree.package;
        target = "/dtbs/${config.boot.kernelPackages.kernel.version}";
      }
    ];
  };
}
