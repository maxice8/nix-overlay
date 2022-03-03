{ pkgs, lib, stdenv, cmake, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "ydotool";
  version = "1.0.1";

  meta = with lib; {
    description = "client and daemon that uses uinput to simulate keypress";
    homepage = "https://github.com/ReimuNotMoe/ydotool";
    license = licenses.agpl3;
    platforms = platforms.linux;
  };

  src = fetchFromGitHub {
    owner = "ReimuNotMoe";
    repo = "ydotool";
    rev = "v${version}";
    hash = "sha256-maXXGCqB8dkGO8956hsKSwM4HQdYn6z1jBFENQ9sKcA=";
  };

  buildInputs = [
    pkgs.cmake
    pkgs.scdoc
  ];
}
