{
  description = "overlay for pkgs and vim modules";

  inputs = {
    # We track this, if you are using this you really want
    # to set inputs.<this-module>.inputs.nixpkgs.follows = "nixpkgs"
    # so that this overlay uses the same underlying derivations
    # that is used in your system flake.nix
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # Source for packages, we pass them as the inputs variable
    ydotool-src = {
      url = "github:ReimuNotMoe/ydotool";
      flake = false;
    };
    abuild-src = {
      type = "gitlab";
      host = "gitlab.alpinelinux.org";
      owner = "alpine";
      repo = "abuild";
      flake = false;
    };
    lc0-src = {
      url = "https://github.com/LeelaChessZero/lc0.git";
      flake = false;
      type = "git";
      submodules = true;
    };

    # plugins, each input here is automatically packaged
    # as a plugin and made available in vimPlugins (if you
    # add us to your overlay ;) )
    kanagawa-nvim = {
      url = "github:rebelot/kanagawa.nvim";
      flake = false;
    };
    vim-scdoc = {
      url = "github:gpanders/vim-scdoc";
      flake = false;
    };
    apkbuild-vim = {
      type = "gitlab";
      host = "gitlab.alpinelinux.org";
      owner = "Leo";
      repo = "apkbuild.vim";
      flake = false;
    };
  };

  outputs =
    { self
    , ...
    }@inputs:
      with inputs;
      let
        inherit (flake-utils.lib) eachSystem system flattenTree;
      in
      eachSystem [ system.aarch64-linux system.i686-linux system.x86_64-linux ]
        (currentSystem:
        let
          pkgs = import nixpkgs {
            system = currentSystem;
            config = { allowUnfree = true; };
          };
        in
        {
          packages = {
            ydotool = pkgs.callPackage ./packages/ydotool { src = inputs.ydotool-src; };
            abuild = pkgs.callPackage ./packages/abuild { src = inputs.abuild-src; };
          } // pkgs.lib.optionalAttrs (currentSystem == system.x86_64-linux) {
            lc0 = pkgs.callPackage ./packages/lc0 { src = inputs.lc0-src; };
          };
        }) //
      {
        overlays.default = import ./overlays inputs;
      };
}
