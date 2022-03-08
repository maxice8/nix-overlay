self: super:
let
  orig-abuild = super.callPackage <nixpkgs/pkgs/development/tools/abuild> { };
in
{
  abuild = orig-abuild.overrideAttrs ( old: rec {
    version = "3.9.0";
    src = super.fetchFromGitLab rec {
      domain = "gitlab.alpinelinux.org";
      owner = "alpine";
      repo = "abuild";
      rev = version;
      sha256 = "1zs8slaqiv8q8bim8mwfy08ymar78rqpkgqksw8y1lsjrj49fqy4";
    };
  });
}
