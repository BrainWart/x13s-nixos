{
  runCommand,
  buildEnv,
  firmwareFilesList ? [ ],
}:
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
  }
  ''
    PS4=" $ "
    (
    set -x
    mkdir -p $out/share/
    ln -s $firmwareFiles/lib/firmware/ $out/share/uncompressed-firmware
    )
  ''
