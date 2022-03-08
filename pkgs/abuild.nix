self: super:
{
  abuild = super.abuild.overrideAttrs ( old: rec {
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
