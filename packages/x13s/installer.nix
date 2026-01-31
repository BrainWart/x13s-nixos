{
  pkgs ? (
    let
      flakeLock = (builtins.fromJSON (builtins.readFile ../../flake.lock));
      source =
        with flakeLock.nodes.nixpkgs.locked;
        fetchTarball {
          url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
        };
    in
    import source { }
  ),
}:
let
  nixosSystem =
    args:
    (import "${pkgs.path}/nixos/lib/eval-config.nix") (
      {
        lib = pkgs.lib;
        system = null;
      }
      // args
    );
in
(nixosSystem ({
  modules = [
    (
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

        boot = {
          supportedFilesystems.zfs = pkgs.lib.mkForce false;

          kernelParams = [
            "modprobe.blacklist=qcom_q6v5_pas"
          ];

          initrd = {
            extraFirmwarePaths = [
              # pkgs.linux-firmware

              "ath11k/WCN6855/hw2.1/amss.bin"
              "qca/hpbtfw21.tlv"
              "qca/hpnv21.bin"
              "qcom/a660_gmu.bin"
              "qcom/a660_sqe.fw"
              "qcom/sc8280xp/LENOVO/21BX/adspr.jsn"
              "qcom/sc8280xp/LENOVO/21BX/adspua.jsn"
              "qcom/sc8280xp/LENOVO/21BX/audioreach-tplg.bin"
              "qcom/sc8280xp/LENOVO/21BX/battmgr.jsn"
              "qcom/sc8280xp/LENOVO/21BX/cdspr.jsn"
              "qcom/sc8280xp/LENOVO/21BX/qcadsp8280.mbn"
              "qcom/sc8280xp/LENOVO/21BX/qccdsp8280.mbn"
              "qcom/sc8280xp/LENOVO/21BX/qcdxkmsuc8280.mbn"
              "qcom/sc8280xp/LENOVO/21BX/qcslpi8280.mbn"
              "qcom/sc8280xp/LENOVO/21BX/qcvss8280.mbn"

            ]
            ++ [

              # pkgs.wireless-regdb
              "regulatory.db"
            ];

            availableKernelModules = [

              "qrtr_mhi"
              "ath11k_pci"
              "ath11k"
              "mac80211"
              "cfg80211"
              "libarc4"
              "btrfs"
              "xor"
              "xor_neon"
              "raid6_pq"
              "ufs"
              "qnx4"
              "hfsplus"
              "hfs"
              "cdrom"
              "minix"
              "msdos"
              "jfs"
              "nls_ucs2_utils"
              "xfs"
              "ext2"
              "rfcomm"
              "snd_seq_dummy"
              "snd_hrtimer"
              "snd_seq"
              "snd_seq_device"
              "algif_hash"
              "algif_skcipher"
              "af_alg"
              "bnep"
              "xt_conntrack"
              "nf_conntrack"
              "nf_defrag_ipv6"
              "nf_defrag_ipv4"
              "xt_tcpudp"
              "ip6t_rpfilter"
              "ipt_rpfilter"
              "xt_pkttype"
              "nft_compat"
              "x_tables"
              "nf_tables"
              "sch_fq_codel"
              "fuse"
              "nfnetlink"
              "dmi_sysfs"
              "uas"
              "hci_uart"
              "btqca"
              "btbcm"
              "bluetooth"
              "qcom_camss"
              "videobuf2_dma_sg"
              "videobuf2_memops"
              "videobuf2_v4l2"
              "ecdh_generic"
              "mhi_wwan_mbim"
              "mhi_wwan_ctrl"
              "qcom_pm8008_regulator"
              "wwan"
              "ov5675"
              "qcom_spmi_adc_tm5"
              "rfkill"
              "videobuf2_common"
              "v4l2_fwnode"
              "qcom_pon"
              "ecc"
              "qcom_spmi_adc5"
              "qcom_vadc_common"
              "rtc_pm8xxx"
              "mousedev"
              "joydev"
              "qcom_spmi_temp_alarm"
              "qcom_pm8008"
              "hid_multitouch"
              "v4l2_async"
              "i2c_hid_of_elan"
              "videodev"
              "qcom_stats"
              "mc"
              "i2c_qcom_cci"
              "camcc_sc8280xp"
              "qcom_edac"
              "icc_bwmon"
              "mhi_pci_generic"
              "gpi"
              "phy_qcom_qmp_usb"
              "mhi"
              "phy_qcom_snps_femto_v2"
              "pci_pwrctrl_pwrseq"
              "snd_soc_lpass_wsa_macro"
              "snd_soc_lpass_rx_macro"
              "snd_soc_lpass_tx_macro"
              "snd_soc_lpass_va_macro"
              "soundwire_qcom"
              "icc_osm_l3"
              "qcom_wdt"
              "snd_soc_lpass_macro_common"
              "lpasscc_sc8280xp"
              "slimbus"
              "pinctrl_sc8280xp_lpass_lpi"
              "pinctrl_lpass_lpi"
              "qcom_rng"
              "ucsi_glink"
              "typec_ucsi"
              "qcomtee"
              "pwrseq_qcom_wcn"
              "snd_soc_sc8280xp"
              "pwrseq_core"
              "snd_soc_qcom_sdw"
              "sm4"
              "snd_soc_qcom_common"
              "snd_soc_wcd938x"
              "qcom_battmgr"
              "snd_soc_wcd938x_sdw"
              "snd_soc_wcd_common"
              "snd_soc_wcd_classh"
              "snd_soc_wcd_mbhc"
              "regmap_sdw"
              "soundwire_bus"
              "socinfo"
              "snd_soc_hdmi_codec"
              "snd_soc_core"
              "snd_compress"
              "ac97_bus"
              "snd_pcm_dmaengine"
              "snd_pcm"
              "snd_timer"
              "snd"
              "soundcore"
              "pwm_bl"
              "pmic_glink_altmode"
              "aux_hpd_bridge"
              "qrtr"
              "pmic_glink"
              "pdr_interface"
              "qcom_pdr_msg"
              "qmi_helpers"
              "phy_qcom_edp"
              "phy_qcom_qmp_pcie"
              "phy_qcom_qmp_combo"
              "aux_bridge"
              "panel_edp"
              "overlay"
              "nvme"
              "nvme_core"
              "nvme_keyring"
              "nvme_auth"
              "hkdf"
              "nls_iso8859_1"
              "nls_cp437"
              "msm"
              "ubwc_config"
              "mdt_loader"
              "llcc_qcom"
              "ocmem"
              "drm_gpuvm"
              "gpu_sched"
              "drm_exec"
              "drm_dp_aux_bus"
              "drm_display_helper"
              "cec"
              "leds_qcom_lpg"
              "qcom_pbs"
              "led_class_multicolor"
              "i2c_qcom_geni"
              "i2c_hid_of"
              "i2c_hid"
              "scsi_transport_fc"
              "gpucc_sc8280xp"
              "gpio_sbu_mux"
              "typec"
              "thunderbolt"
              "dm_mod"
              "dax"
              "dispcc_sc8280xp"

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
    )
  ];
}))
