{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, pkg-config
, mkl
, openblas
, eigen
, dnnl
, zlib
, python3
}:
stdenv.mkDerivation rec {
  pname = "lc0";
  version = "master";

  src = fetchFromGitHub {
    owner = "LeelaChessZero";
    repo = "lc0";
    rev = "025105e2f96978f1a4b69df9d20ab20d223a3a41";
    sha256 = "16dmdkc14xx4c6q99dfp2qjr4msv18dn2djkj43krklvsk1jnbbr";
    fetchSubmodules = true;
  };

  buildInputs = [
    mkl
    openblas
    eigen
    dnnl
    zlib
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
  ];

  mesonFlags = [
    "-Dblas=true"
    "-Dopenblas_include=${openblas}/include"
    "-Dopenblas_libdirs=${openblas}/lib"
    "-Dmkl=true"
    "-Dmkl_include=${mkl}/include"
    "-Dmkl_libdirs=${mkl}/lib"
    "-Ddnnl=true"
    "-Ddnnl_dir=${dnnl}"
    "-Donednn=false"
    "-Dgtest=false"
  ];

  # This is called during the build process
  postPatch = ''
    patchShebangs scripts/compile_proto.py
  '';

  meta = with lib; {
    description = "Open source neural network based chess engine";
    homepage = "https://lczero.org";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
