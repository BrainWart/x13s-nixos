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
        "ac97_bus"
        "af_alg"
        "algif_hash"
        "algif_skcipher"
        "arm-smmu"
        "ath11k_pci"
        "ath11k"
        "aux_bridge"
        "aux_hpd_bridge"
        "bluetooth"
        "bnep"
        "btbcm"
        "btqca"
        "btrfs"
        "camcc-sc8280xp"
        "cdrom"
        "cec"
        "cfg80211"
        "clk-rpmh"
        "cmd-db"
        "dax"
        "dispcc-sc8280xp" # "disp_cc-sc8280xp"
        "dm_mod"
        "dmi_sysfs"
        "drm_display_helper"
        "drm_dp_aux_bus"
        "drm_exec"
        "drm_gpuvm"
        "dummy"
        "dwc3"
        "dwc3-qcom-legacy"
        "ecc"
        "ecdh_generic"
        "ext2"
        "fuse"
        "gcc-sc8280xp"
        "i2c-qcom-geni" # "geni_i2c"
        "gpi"
        "gpio-keys"
        "gpio_sbu_mux"
        "gpu_sched"
        "gpucc-sc8280xp" # "gpu_cc-sc8280xp"
        "hci_uart" # "hci_uart_qca"
        "hfs"
        "hfsplus"
        "hid_multitouch"
        "hid-generic"
        "hid-multitouch"
        "hkdf"
        "i2c_hid_of_elan"
        "i2c_hid_of"
        "i2c_hid"
        "i2c-qcom-cci"
        "icc_bwmon"
        "ip6t_rpfilter"
        "ipt_rpfilter"
        "jfs"
        "joydev"
        "led_class_multicolor"
        "leds_qcom_lpg"
        "leds-gpio"
        "libarc4"
        "lpasscc-sc8280xp"
        "mac80211"
        "mc"
        "mdt_loader"
        "mhi-pci-generic"
        "mhi_wwan_ctrl"
        "mhi_wwan_mbim"
        "mhi-pci-generic"
        "mhi"
        "minix"
        "mousedev"
        "msdos"
        "msm"
        "nf_conntrack"
        "nf_defrag_ipv4"
        "nf_defrag_ipv6"
        "nf_tables"
        "nfnetlink"
        "nft_compat"
        "nls_cp437"
        "nls_iso8859_1"
        "nls_ucs2_utils"
        "nvme_auth"
        "nvme_core"
        "nvme_keyring"
        "nvme"
        "icc-osm-l3" # "osm-l3"
        "ocmem"
        "ov5675"
        "overlay"
        "panel_edp"
        "pci-pwrctrl-pwrseq"
        "pdr_interface"
        "pinctrl_lpass_lpi"
        "pinctrl_sc8280xp_lpass_lpi"
        "qcom-pm8008" # "pm8008"
        "pm8941-pwrkey"
        "pmic_glink_altmode"
        "pmic_glink"
        "pwm_bl"
        "pwrseq_core"
        "pwrseq-qcom_wcn"
        "qcom_battmgr"
        "qcom-camss"
        "qcom-cpufreq-hw"
        "phy-qcom-edp" # "qcom-edp-phy"
        "qcom_edac"
        "qcom_geni_serial"
        "qcom_hwspinlock"
        "qcom_pbs"
        "qcom_pdr_msg"
        "qcom_pon"
        "qcom_spmi_adc_tm5"
        "qcom_spmi_temp_alarm"
        "qcom_vadc_common"
        "qcom-ipcc"
        "llcc-qcom" # "qcom-llcc"
        "qcom_pdc"
        "qcom-pm8008-regulator"
        "qcom-pon"
        "phy-qcom-qmp-combo" # "qcom-qmp-combo-phy"
        "phy-qcom-qmp-pcie" # "qcom-qmp-pcie-phy"
        "phy-qcom-qmp-usb" # "qcom-qmp-usb-phy"
        "qcom_qseecom"
        "qcom_qseecom_uefisecapp"
        "qcom_rng"
        "qcom-rpmh-regulator"
        "qcom_scm"
        "phy-qcom-snps-femto-v2" # "qcom-snps-hs-femto-v2-phy"
        "socinfo" # "qcom-socinfo"
        "qcom-spmi-adc5"
        "qcom-spmi-adc-tm5"
        "qcom_stats"
        "qcomtee"
        "qcom-spmi-adc5"
        "qcom-tsens"
        "qcom_wdt"
        "qmi_helpers"
        "qnoc-sc8280xp"
        "qnx4"
        "qrtr_mhi"
        "qrtr"
        "raid6_pq"
        "regmap_sdw"
        "rfcomm"
        "rfkill"
        "rtc-pm8xxx"
        "sch_fq_codel"
        "scsi_transport_fc"
        "slimbus"
        "sm4"
        "snd_compress"
        "snd_hrtimer"
        "snd_pcm_dmaengine"
        "snd_pcm"
        "snd_seq_device"
        "snd_seq_dummy"
        "snd_seq"
        "snd_soc_core"
        "snd_soc_hdmi_codec"
        "snd_soc_lpass_macro_common"
        "snd_soc_lpass_rx_macro"
        "snd_soc_lpass_tx_macro"
        "snd_soc_lpass_va_macro"
        "snd_soc_lpass_wsa_macro"
        "snd_soc_qcom_common"
        "snd_soc_qcom_sdw"
        "snd_soc_sc8280xp"
        "snd_soc_wcd_classh"
        "snd_soc_wcd_common"
        "snd_soc_wcd_mbhc"
        "snd_soc_wcd938x_sdw"
        "snd_soc_wcd938x"
        "snd_timer"
        "snd"
        "soundcore"
        "soundwire_bus"
        "soundwire_qcom"
        "spmi_pmic_arb"
        "qcom-spmi-temp-alarm" # "spmi-temp-alarm"
        "thunderbolt"
        "typec_ucsi"
        "typec"
        "uas"
        "ubwc_config"
        "ucsi_glink" # "ucsi_glink.pmic_glink_ucsi"
        "ufs"
        "usb-storage"
        "v4l2_async"
        "v4l2_fwnode"
        "videobuf2_common"
        "videobuf2_dma_sg"
        "videobuf2_memops"
        "videobuf2_v4l2"
        "videodev"
        "wwan"
        "x_tables"
        "xfs"
        "xhci-hcd"
        "xor_neon"
        "xor"
        "xt_conntrack"
        "xt_pkttype"
        "xt_tcpudp"
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
