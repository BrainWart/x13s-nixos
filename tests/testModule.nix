{
  pkgs ? (
    let
      flakeLock = (builtins.fromJSON (builtins.readFile ../flake.lock));
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
        pkgs = pkgs;
        system = null;
      }
      // args
    );

  x13sSystem =
    extraModule:
    (nixosSystem ({
      modules = [
        {
          imports = [
            ../module.nix
          ];

          nixos-x13s.enable = true;

          nixpkgs.hostPlatform = "aarch64-linux";
          system.stateVersion = "25.11";
        }
        extraModule
      ];
    }));
in
pkgs.lib.runTests {
  testKernelJhovoldDefault = {
    expected = pkgs.callPackage ../packages/x13s/linux_jhovold/package.nix { };
    expr = (x13sSystem { }).config.boot.kernelPackages.kernel;
  };

  testKernelPackagesWillSet = {
    expected = pkgs.linuxPackages_latest.kernel;
    expr =
      (x13sSystem {
        boot.kernelPackages = pkgs.linuxPackages_latest;
      }).config.boot.kernelPackages.kernel;
  };

  testOptionKernelJhovold = {
    expected = pkgs.callPackage ../packages/x13s/linux_jhovold/package.nix { };
    expr =
      (x13sSystem {
        nixos-x13s.kernel = "jhovold";
      }).config.boot.kernelPackages.kernel;
  };

  testOptionKernelMainline = {
    expected = pkgs.linux_latest;
    expr =
      (x13sSystem {
        nixos-x13s.kernel = "mainline";
      }).config.boot.kernelPackages.kernel;
  };

  testOptionKernelPackage = {
    expected = pkgs.linux_testing;
    expr =
      (x13sSystem {
        nixos-x13s.kernel = pkgs.linux_testing;
      }).config.boot.kernelPackages.kernel;
  };

  testOptionWifiMac =
    let
      mac = "01:02:03:04:05:06";
    in
    {
      expected = [ "address ${mac}" ];
      expr =
        builtins.match ".*(address ${mac}).*"
          (x13sSystem {
            nixos-x13s.wifiMac = mac;
          }).config.services.udev.extraRules;
    };

  testOptionBluetoothMac = {
    expected = true;
    expr =
      (x13sSystem {
        nixos-x13s.bluetoothMac = "01:02:03:04:05:06";
      }).config.systemd.services.bluetooth-x13s-mac.enable;
  };
}
