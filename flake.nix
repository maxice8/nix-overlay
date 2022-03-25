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
    , nixpkgs
    , flake-utils
    , ...
    }@inputs:
    let
      # Define system as defined by flake-utils
      sys = flake-utils.lib.system;
      # List all linux systems using the ${system} definition
      # as that allows us to type-safely instead of relying on
      # not typoing a string
      linuxSystems =
        [
          sys.x86_64-linux
          sys.i686-linux
          sys.aarch64-linux
        ];
    in
    # Loop over all the linux systems
    flake-utils.lib.eachSystem linuxSystems
      (system:
      {
        packages = import ./packages system inputs;
      }) //

    # Define an overlay for each of the default systems
    flake-utils.lib.eachDefaultSystem (system:
    {
      overlays =
        final:
        prev:
        let
          # Define a helper function calld 'buildMaxPlugin',
          # that uses the 'buildVimPluginFrom2Nix' that is
          # available on 'vimUtils'
          #
          # This function takes a 'name', that 'name' must
          # be in the 'inputs' of the flake.nix
          inherit (prev.vimUtils) buildVimPluginFrom2Nix;
          buildMaxPlugin = name: buildVimPluginFrom2Nix {
            pname = name;
            version = "master";
            src = builtins.getAttr name inputs;
          };

          # Create a list of plugins by reading all inputs
          # and ignoring certain input names like 'self'
          # and 'nixpkgs' since those are not meant to be
          # vim plugins
          #
          # we also ignore ones that end with `-src` since
          # those are sources that are passed to builds
          plugins = builtins.filter
            (name:
              name != "self" &&
              name != "nixpkgs" &&
              name != "flake-utils" &&
              !final.lib.hasSuffix "-src" name)
            (builtins.attrNames inputs);
        in
        {
          # Add the ydotool package if our system is inside
          # the list of systems that are linux
          ydotool = final.lib.mkIf (builtins.elem system linuxSystems)
            self.packages.${system}.ydotool;
          lc0 = final.lib.mkIf (builtins.elem system [ sys.x86_64-linux ])
            self.packages.${system}.lc0;
          abuild = final.lib.mkIf (builtins.elem system linuxSystems)
            self.packages.${system}.abuil;

          # UPDATE vimPlugins with the list of plugins
          vimPlugins = prev.vimPlugins //
          builtins.listToAttrs
            (map (name: { inherit name; value = buildMaxPlugin name; }) plugins);
        };
    });
}
