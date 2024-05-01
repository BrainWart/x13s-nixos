{
  stdenv,
  fetchurl,
  innoextract,
}:

stdenv.mkDerivation {
  name = "uefi";
  version = "1.60";

  src = fetchurl {
    url = "https://download.lenovo.com/pccbbs/mobiles/n3huj19w.exe";
    hash = "sha256-ZSjkvbMb0e9CoL2OYo3Aioyz3or1YkOX/BdOOeAuL7I=";
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
