{
  fetchurl,
  innoextract,
  stdenv,
  writeScriptBin,
  pkgs,
}:

stdenv.mkDerivation {
  name = "uefi";
  version = "1.63";

  src = fetchurl {
    url = "https://download.lenovo.com/pccbbs/mobiles/n3huj21w.exe";
    hash = "sha256-uFIDAX8JKgLfFv9G4npO7xljT32Fau8VY3B7IcuHeyo=";
  };

  nativeBuildInputs = [ innoextract ];

  unpackPhase = ''
    innoextract $src
  '';

  doBuild = false;

  installPhase = ''
    mkdir --parent $out/{EFI/Boot,Flash}
    cp code\$GetExtractPath\$/Rfs/Usb/Bootaa64.efi $out/EFI/Boot/
    cp -r code\$GetExtractPath\$/Rfs/Fw/* $out/Flash/
  '';
}
// {
  getLatestUefiUrl = writeScriptBin "get-latest-uefi-url" ''
    curl --silent --fail \
      --header 'Referer: https://pcsupport.lenovo.com/us/en/products/laptops-and-netbooks/thinkpad-x-series-laptops/thinkpad-x13s-type-21bx-21by/downloads/driver-list/' \
      'https://pcsupport.lenovo.com/us/en/api/v4/downloads/drivers?productId=laptops-and-netbooks%2Fthinkpad-x-series-laptops%2Fthinkpad-x13s-type-21bx-21by' \
    | ${pkgs.jq}/bin/jq --raw-output '.body.DownloadItems[] | select(.Title | startswith("BIOS Update")) | .Files[] | select(.TypeString == "EXE") | .URL'
  '';
}
