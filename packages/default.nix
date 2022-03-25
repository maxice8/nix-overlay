system: inputs:
let
  inherit inputs system;
  pkgs = import inputs.nixpkgs {
    inherit system;
    config = { allowUnfree = true; };
  };
in
{
  ydotool = pkgs.callPackage ./ydotool { src = inputs.ydotool-src; };
  abuild = pkgs.callPackage ./abuild { src = inputs.abuild-src; };
} // pkgs.lib.optionalAttrs (system == inputs.flake-utils.lib.system.x86_64-linux) {
  # This package requires Intel's MKL which is only availble on
  # x86_64-linux
  lc0 = pkgs.callPackage ./lc0 { src = inputs.lc0-src; };
}
