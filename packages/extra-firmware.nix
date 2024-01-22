{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation {
  pname = "x13s-extra-firmware";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "ironrobin";
    repo = "x13s-alarm";
    rev = "efa51c3b519f75b3983aef67855b1561d9828771";
    sha256 = "sha256-weETbWXz9aL2pDQDKk7fkb1ecQH0qrhUYDs2E5EiJcI=";
  };

  dontFixup = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/lib/firmware/qcom/sc8280xp/LENOVO/21BX
    cp x13s-firmware/qcvss8280.mbn $out/lib/firmware/qcom/sc8280xp/LENOVO/21BX/
  '';
}
