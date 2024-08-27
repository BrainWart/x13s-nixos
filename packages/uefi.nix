{
  stdenv,
  fetchurl,
  innoextract,
}:

stdenv.mkDerivation {
  name = "uefi";
  version = "1.60";

  src = fetchurl {
    # # Get the latest BIOS Update URL
    # curl --silent --fail \
    #   --header 'Referer: https://pcsupport.lenovo.com/us/en/products/laptops-and-netbooks/thinkpad-x-series-laptops/thinkpad-x13s-type-21bx-21by/downloads/driver-list/' \
    #   'https://pcsupport.lenovo.com/us/en/api/v4/downloads/drivers?productId=laptops-and-netbooks%2Fthinkpad-x-series-laptops%2Fthinkpad-x13s-type-21bx-21by' \
    # | jq '.body.DownloadItems[] | select(.Title | startswith("BIOS Update")) | .Files[] | select(.TypeString == "EXE") | .URL'

    url = "https://download.lenovo.com/pccbbs/mobiles/n3huj20w.exe";
    hash = "sha256-A3l/ZfIbFcvFX+bMWYgpW+1kkYPu5MQkuTCgszhaoIY=";
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
