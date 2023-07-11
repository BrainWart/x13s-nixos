# Source: https://github.com/cenunix/x13s-nixos/tree/main

{ lib
, fetchzip
, stdenvNoCC 
}:

  stdenvNoCC.mkDerivation rec {
   pname = "x13s-firmware";
   version = "1.0.0";

   src = fetchzip {
    url = "https://github.com/cenunix/x13s-firmware/releases/download/1.0.0/x13s-firmware.tar.gz";
    sha256 = "sha256-cr0WMKbGeJyQl5S8E7UEB/Fal6FY0tPenEpd88KFm9Q=";
    stripRoot = false;
    };
    dontFixup = true;

 installPhase = ''
   runHook preInstall
   mkdir -p $out/lib/firmware/qcom/sc8280xp/LENOVO/21BX
   mkdir -p $out/lib/firmware/qca
   mkdir -p $out/lib/firmware/ath11k/WCN6855/hw2.0/
   cp -av my-repo/a690_gmu.bin $out/lib/firmware/qcom
   cp -av my-repo/qcvss8280.mbn $out/lib/firmware/qcom/sc8280xp/LENOVO/21BX
   cp my-repo/SC8280XP-LENOVO-X13S-tplg.bin $out/lib/firmware/qcom/sc8280xp 
   cp -av my-repo/hpnv21.8c $out/lib/firmware/qca/hpnv21.b8c
   cp -av my-repo/board-2.bin $out/lib/firmware/ath11k/WCN6855/hw2.0
   runHook postInstall
 '';
}
