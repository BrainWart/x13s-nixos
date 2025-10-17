{
  config,
  lib,
  pkgs,
  stable-nixpkgs,
  ...
}:
let
  dtbName = "sc8280xp-lenovo-thinkpad-x13s.dtb";
  cfg = config.nixos-x13s;

  linuxPackages =
    if lib.isDerivation cfg.kernel then
      pkgs.linuxPackagesFor cfg.kernel
    else if lib.isString cfg.kernel then
      if cfg.kernel == "mainline" then
        pkgs.linuxPackages_latest
      else if cfg.kernel == "jhovold" then
        pkgs.linuxPackagesFor pkgs.x13s.linux_jhovold
      else
        throw "unsupported enum value for kernel. use a kernel package instead. eg: pkgs.linux_latest"
    else
      throw "unsupported type for kernel!";

  dtb = "${linuxPackages.kernel}/dtbs/qcom/${dtbName}";
  dtbEfiPath = "dtbs/x13s-${linuxPackages.kernel.version}.dtb";

  modulesClosure = pkgs.makeModulesClosure {
    rootModules = config.boot.initrd.availableKernelModules ++ config.boot.initrd.kernelModules;
    kernel = config.system.modulesTree;
    firmware = config.hardware.firmware;
    allowMissing = false;
  };

  modulesWithExtra = pkgs.symlinkJoin {
    name = "modules-closure";
    paths = [
      modulesClosure
      pkgs.x13s.firmware.graphics
    ];
  };
in
{
  options.nixos-x13s = {
    enable = lib.mkEnableOption "x13s hardware support";

    wifiMac = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "WiFi MAC address to set on boot";
      default = null;
    };

    bluetoothMac = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Bluetooth MAC address to set on boot";
      default = null;
    };

    kernel = lib.mkOption {
      type = lib.types.oneOf [
        lib.types.package
        (lib.types.enum [
          "jhovold"
          "mainline"
        ])
      ];
      description = "'jhovold', 'mainline', or a linux package";
      default = pkgs.x13s.linux_jhovold;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.efibootmgr ];

    hardware.enableAllFirmware = true;
    hardware.firmware = lib.mkBefore [ pkgs.x13s.firmware.graphics ];

    boot = {
      initrd.systemd.enable = true;
      initrd.systemd.contents = {
        "/lib".source = lib.mkForce "${modulesWithExtra}/lib";
      };

      loader.efi.canTouchEfiVariables = true;
      loader.systemd-boot.enable = lib.mkDefault true;
      loader.systemd-boot.extraFiles = {
        "${dtbEfiPath}" = dtb;
      };

      kernelPackages = lib.mkForce linuxPackages;

      kernelParams = [
        # needed to boot
        "dtb=${dtbEfiPath}"

        # jhovold recommended
        "efi=noruntime" # No longer needed if "Linux Boot" is enabled a recent version of the UEFI
        "clk_ignore_unused"
        "pd_ignore_unused"
        "arm64.nopauth"
        # "regulator_ignore_unused" # allows for > 30 sec to load msm, at the potential cost of power
      ];

      initrd = {
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

    # https://github.com/jhovold/linux/wiki/X13s#modem
    networking.networkmanager.fccUnlockScripts = [
      {
        id = "105b:e0c3";
        path = "${pkgs.modemmanager}/share/ModemManager/fcc-unlock.available.d/105b";
      }
    ];

    nixpkgs.overlays = [
      (
        _: super:
        (
          {
            # don't try and use zfs
            zfs = super.zfs.overrideAttrs (_: {
              meta.platforms = [ ];
            });

            # allow missing modules
            makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
          }
          # add our custom x13s packages
          // (lib.packagesFromDirectoryRecursive {
            callPackage = pkgs.callPackage;
            directory = ./packages;
          })
        )
      )
    ];

    # default is performance
    powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

    # https://github.com/jhovold/linux/wiki/X13s#camera
    services.udev.extraRules = lib.strings.concatLines (
      [
        ''
          ACTION=="add", SUBSYSTEM=="dma_heap", KERNEL=="linux,cma", GROUP="video", MODE="0660"
          ACTION=="add", SUBSYSTEM=="dma_heap", KERNEL=="system", GROUP="video", MODE="0660"
        ''
      ]
      ++ (
        if cfg.wifiMac != null then
          [
            ''
              ACTION=="add", SUBSYSTEM=="net", KERNELS=="0006:01:00.0", RUN+="${pkgs.iproute2}/bin/ip link set dev $name address ${cfg.wifiMac}"
            ''
          ]
        else
          [ ]
      )
    );

    systemd.services.bluetooth-x13s-mac = lib.mkIf (cfg.bluetoothMac != null) {
      wantedBy = [ "multi-user.target" ];
      before = [ "bluetooth.service" ];
      requiredBy = [ "bluetooth.service" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        # Bluez 5.83 has critical bug with qualcomm adapter
        # https://github.com/bluez/bluez/issues/1394
        ExecStart = "${pkgs.util-linux}/bin/script -q -c '${stable-nixpkgs.bluez}/bin/btmgmt --index 0 public-addr ${cfg.bluetoothMac}'";
      };
    };
  };
}
