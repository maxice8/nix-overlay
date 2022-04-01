{ src
, lib
, stdenv
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

  inherit src;

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
