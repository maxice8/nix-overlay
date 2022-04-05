{ stdenvNoCC
, lib
, makeWrapper
, delta
, less
}:
stdenvNoCC.mkDerivation {
  pname = "delta";
  inherit (delta) version;
  nativeBuildInputs = [ makeWrapper ];

  # Using `buildCommand` replaces the original packages build phases.
  buildCommand = ''
      set -eo pipefail

      ${
        # Copy original files, for each split-output (`out`, `dev` etc.).
        # E.g. `${package.dev}` to `$dev`, and so on. If none, just "out".
        # Symlink all files from the original package to here (`cp -rs`),
        # to save disk space.
        # We could alternatiively also copy (`cp -a --no-preserve=mode`).
        lib.concatStringsSep "\n"
          (map
            (outputName:
              ''
                echo "Copying output ${outputName}"
                set -x
                cp -rs --no-preserve=mode "${delta.${outputName}}" "''$${outputName}"
                set +x
              ''
            )
            (delta.outputs or ["out"])
          )
      }

    # All for this here exactly
    wrapProgram ${placeholder "out"}/bin/delta \
      --set PAGER ${less}/bin/less
  '';
}


