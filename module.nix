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

        systemd.services.bluetooth-x13s-mac = {
          wantedBy = [ "multi-user.target" ];
          before = [ "bluetooth.service" ];
          requiredBy = [ "bluetooth.service" ];

          script = ''
            BLUETOOTH_MAC="${if cfg.bluetoothMac == null then "" else cfg.bluetoothMac}"

            if [ "$BLUETOOTH_MAC" = "" ] ; then
              # we might be able to use the system serial number but, if we lost machine-id
              # the system has probably lost the bluetooth device keys anyway
              RANDOM=$(( $(cat /etc/machine-id | head -c 128 | sed -e 's/[^0-9]//g;s/^0*//') ))

              # https://datatracker.ietf.org/doc/html/rfc7042#section-2.1
              # > Two bits within the initial octet of an EUI-48 have special
              # > significance in MAC addresses: the Group bit (01) and the Local bit
              # > (02).  OUIs and longer MAC prefixes are assigned with the Local bit
              # > zero and the Group bit unspecified.  Multicast identifiers may be
              # > constructed by turning on the Group bit, and unicast identifiers may
              # > be constructed by leaving the Group bit zero.
              #
              # First, and only argument is for passing a file to seed RANDOM.
              # recommend using `/etc/machine-id` to pin the mac address if needed.
              
              BLUETOOTH_MAC="$(printf '%X%X:%02X:%02X:%02X:%02X:%02X' \
                $[RANDOM%16] $[((RANDOM%4)+1)*4-2] \
                $[RANDOM%256] \
                $[RANDOM%256] \
                $[RANDOM%256] \
                $[RANDOM%256] \
                $[RANDOM%256])"
            fi

            ${pkgs.bluez}/bin/btmgmt --index 0 public-addr $BLUETOOTH_MAC
          '';

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
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
