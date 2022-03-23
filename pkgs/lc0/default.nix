{ inputs
, lib
, stdenv
, fetchFromGitHub
, fetchpatch
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

  src = inputs.lc0-src;

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

  patches = [
    (fetchpatch {
      url = "https://github.com/Tilps/lc0/commit/6278b4501a3bfa125c7ebd564f2a51c749568d75.patch";
      sha256 = "sha256-5XRBN/8a6aCVECBzIVDfuc5ooQRXSGl/+0z46HA/JN4=";
    })
    (fetchpatch {
      url = "https://github.com/Tilps/lc0/commit/0a778d515b331de3da9714d2906439a2b4a58280.patch";
      sha256 = "sha256-di5q8PQJ1Mu6JWnze/+8FYElWTAdA/KgrNDW833OZSc=";
    })
    (fetchpatch {
      url = "https://github.com/Tilps/lc0/commit/9b12bf435e67cff71f42aa3e77c2b18e59840257.patch";
      sha256 = "sha256-tkA2Equ6RnDQC5D26Ob2dHJpiBu+I/SEuWDOmyJR/k4=";
    })
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
