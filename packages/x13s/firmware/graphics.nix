{
  fetchurl,
  innoextract,
  lib,
  stdenv,
}:
let
  allDownloads = (builtins.fromJSON (builtins.readFile ./lenovo-downloads.json)).body.DownloadItems;
  downloads = builtins.concatLists (
    builtins.map (d: d.Files) (builtins.filter (d: lib.hasInfix "Graphics Driver" d.Title) allDownloads)
  );
  sortedDownloads = builtins.sort (a: b: a.Date.Unix > b.Date.Unix) downloads;
  exeDownload = builtins.head (builtins.filter (d: d.TypeString == "EXE") sortedDownloads);
  versionName = lib.toUpper (
    builtins.head (builtins.match "^.+/([a-zA-Z0-9]+).exe$" exeDownload.URL)
  );
in
stdenv.mkDerivation {
  name = "graphics-firmware";
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
  dontFixup = true;

  installPhase = ''
    mkdir -vp "$out/lib/firmware/qcom/sc8280xp/LENOVO/21BX"
    cp -v code\$GetExtractPath\$/${versionName}/**/*.mbn "$out/lib/firmware/qcom/sc8280xp/LENOVO/21BX/"
  '';

  meta = {
    license = lib.licenses.unfree;
  };
}
