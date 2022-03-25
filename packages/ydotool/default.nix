{ src
, stdenv
, lib
, fetchFromGitHub
, cmake
, scdoc
, util-linux
}:

stdenv.mkDerivation rec {
  pname = "ydotool";
  version = "master";

  inherit src;

  nativeBuildInputs = [
    cmake
    scdoc
  ];

  # fix call of /usr/bin/kill
  postInstall = ''
    substituteInPlace ${placeholder "out"}/lib/systemd/user/ydotool.service \
      --replace '/usr/bin/kill' '${util-linux}/bin/kill'
  '';

  meta = with lib; {
    description = "client and daemon that uses uinput to simulate keypress";
    homepage = "https://github.com/ReimuNotMoe/ydotool";
    license = licenses.agpl3;
    platforms = platforms.linux;
  };
}
