{
  fetchurl,
  innoextract,
  lib,
  stdenv,
}:
let
  allDownloads = (builtins.fromJSON (builtins.readFile ./lenovo-downloads.json));
  downloads = builtins.concatLists (
    builtins.map (d: d.Files) (builtins.filter (d: lib.hasInfix "BIOS Update" d.Title) allDownloads)
  );
  sortedDownloads = builtins.sort (a: b: a.Date.Unix > b.Date.Unix) downloads;
  exeDownload = builtins.head (builtins.filter (d: d.TypeString == "EXE") sortedDownloads);
in

stdenv.mkDerivation {
  name = "uefi";
  version = exeDownload.Version;

  src = fetchurl {
    url = exeDownload.URL;
    sha256 = exeDownload.SHA256;
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

  meta = {
    license = lib.licenses.unfree;
  };
}
