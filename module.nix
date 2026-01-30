{
  config,
  lib,
  pkgs,
  ...
}:
let
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
      type = lib.types.nullOr (
        lib.types.oneOf [
          lib.types.package
          (lib.types.enum [
            "jhovold"
            "mainline"
          ])
        ]
      );
      description = "'jhovold', 'mainline', or a linux package";
      default = pkgs.x13s.linux_jhovold;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge ([
      {
        hardware = {
          enableRedistributableFirmware = true;
          deviceTree = {
            enable = true;
            filter = "sc8280xp-lenovo-thinkpad-x13s*.dtb";
            name = "qcom/sc8280xp-lenovo-thinkpad-x13s.dtb";
          };
        };

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
            ExecStart = "${pkgs.util-linux}/bin/script -q -c '${pkgs.bluez}/bin/btmgmt --index 0 public-addr ${cfg.bluetoothMac}'";
          };
        };

        boot = {
          kernelParams = [
            # jhovold recommended
            # "efi=noruntime" # No longer needed if "Linux Boot" is enabled a recent version of the UEFI
            # "clk_ignore_unused"
            # "pd_ignore_unused"
            "arm64.nopauth"
            # "regulator_ignore_unused" # allows for > 30 sec to load msm, at the potential cost of power
          ];

          initrd = {
            kernelModules = [
              "nvme"
              "phy-qcom-qmp-pcie"
              # "pcie-qcom" # this is no longer a module

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
        networking.modemmanager.fccUnlockScripts = [
          {
            id = "105b:e0c3";
            path = "${pkgs.modemmanager}/share/ModemManager/fcc-unlock.available.d/105b";
          }
        ];

        nixpkgs.overlays = [
          (
            _: super:
            (lib.packagesFromDirectoryRecursive {
              callPackage = pkgs.callPackage;
              directory = ./packages;
            })
          )
        ];
      }

      (lib.mkIf (cfg.kernel != null) {
        warnings = [
          "nixos-x13s.kernel is going away. Use `boot.kernelPackages` directly."
        ];

        boot = {
          kernelPackages = lib.mkDefault linuxPackages;
        };
      })

      (lib.mkIf config.boot.loader.systemd-boot.enable {
        boot = {
          kernelParams = [
            "dtb=/dtbs/${config.boot.kernelPackages.kernel.version}/${config.hardware.deviceTree.name}"
          ];
          loader.systemd-boot.extraFiles = {
            "dtbs/${config.boot.kernelPackages.kernel.version}" = "${config.hardware.deviceTree.package}";
          };
        };
      })

      (lib.mkIf config.boot.loader.grub.enable {
        boot = {
          loader.grub = {
            extraConfig = ''
              devicetree /dtbs/${config.boot.kernelPackages.kernel.version}/${config.hardware.deviceTree.name}
            '';
            extraFiles = {
              "dtbs/${config.boot.kernelPackages.kernel.version}" = "${config.hardware.deviceTree.package}";
            };
          };
        };
      })
    ])
  );
}
