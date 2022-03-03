{
  description = "overlay for pkgs and vim modules";

  inputs = {
    # We track this, if you are using this you really want
    # to set inputs.<this-module>.inputs.nixpkgs.follows = "nixpkgs"
    # so that this overlay uses the same underlying derivations
    # that is used in your system flake.nix
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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
    ...
  }@inputs:
  {
    overlay = (final: prev:
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
            name != "nixpkgs")
          (builtins.attrNames inputs);

      in
      {
        # This is just a normal package, not in any way related
        # to vimPlugins, just define it inside the overlay
        ydotool = final.callPackage ./pkgs/ydotool.nix {};
        # UPDATE vimPlugins with the list of plugins
        vimPlugins = prev.vimPlugins //
          builtins.listToAttrs
            (map (name: { inherit name; value = buildMaxPlugin name; }) plugins);
      }
    );
  };
}
