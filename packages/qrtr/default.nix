{
  stdenv,
  lib,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "qrtr";
  version = "unstable-2023-01-17";

  src = fetchFromGitHub {
    owner = "andersson";
    repo = "qrtr";
    rev = "d0d471c96e7d112fac6f48bd11f9e8ce209c04d2";
    hash = "sha256-KF0gCBRw3BDJdK1s+dYhHkokVTHwRFO58ho0IwHPehc=";
  };

  installFlags = [ "prefix=$(out)" ];

  meta = with lib; {
    description = "QMI IDL compiler";
    homepage = "https://github.com/andersson/qrtr";
    license = licenses.bsd3;
    platforms = platforms.aarch64;
  };
}
