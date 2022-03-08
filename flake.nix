{
  description = "overlay for pkgs and vim modules";

  inputs = {
    # We track this, if you are using this you really want
    # to set inputs.<this-module>.inputs.nixpkgs.follows = "nixpkgs"
    # so that this overlay uses the same underlying derivations
    # that is used in your system flake.nix
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

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
      type = "git";
      url = "https://gitlab.alpinelinux.org/Leo/apkbuild.vim.git";
      flake = false;
    };
  };

  outputs = { 
    self,
    nixpkgs,
    flake-utils,
    ...
  }@inputs:
  let
    # Define system as defined by flake-utils
    system = flake-utils.lib.system;
    # List all linux systems using the ${system} definition
    # as that allows us to type-safely instead of relying on
    # not typoing a string
    linuxSystems =
      [
        system.x86_64-linux
        system.i686-linux
        system.aarch64-linux
      ];
  in
  # Loop over all the linux systems
  flake-utils.lib.eachSystem linuxSystems (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # Define packages.${system} to include ydotool
      # this will guarantee that only Linux systems have
      # ydotool which is quite literally made using the
      # Linux uinput device
      packages = {
          ydotool = pkgs.callPackage ./pkgs/ydotool.nix {}; 
      };
    }
  ) //

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
      # NOTE: in the future, if this overlay grows to
      # include inputs related to other packages then
      # we might want to change this so that it excludes
      # everything by default and includes just 'names'
      # that start with 'vimPlugin-' or another specific,
      # defined, prefix.
      plugins = builtins.filter
        (name:
          name != "self" &&
          name != "nixpkgs" &&
          name != "flake-utils")
        (builtins.attrNames inputs);
    in
    {
      # Add the ydotool package if our system is inside
      # the list of systems that are linux
      ydotool = final.lib.mkIf (builtins.elem system linuxSystems)
        self.packages.${system}.ydotool;
      abuild = import ./pkgs/abuild.nix;

      # UPDATE vimPlugins with the list of plugins
      vimPlugins = prev.vimPlugins //
        builtins.listToAttrs
          (map (name: { inherit name; value = buildMaxPlugin name; }) plugins);
    };
  });
}
