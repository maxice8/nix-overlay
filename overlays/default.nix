inputs:
let
  inherit inputs;
in
final: prev:
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
  # UPDATE vimPlugins with the list of plugins
  vimPlugins = prev.vimPlugins //
    builtins.listToAttrs
      (map (name: { inherit name; value = buildMaxPlugin name; }) plugins);

}
