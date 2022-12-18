final: prev: {

  dhall-haskell-stacklock = final.stacklock2nix {
    stackYaml = ../stack.yaml;
  };

  dhall-haskell-pkg-set = final.haskell.packages.ghc8107.override (oldAttrs: {
    overrides = final.lib.composeManyExtensions [
      # Make sure not to lose any old overrides, although in most cases there
      # won't be any.
      (oldAttrs.overrides or (_: _: {}))

      # An overlay with Haskell packages from the Stackage snapshot.
      final.dhall-haskell-stacklock.stackYamlResolverOverlay

      # An overlay with `extraDeps` from `stack.yaml`.
      final.dhall-haskell-stacklock.stackYamlExtraDepsOverlay

      # An overlay with your local packages from `stack.yaml`.
      final.dhall-haskell-stacklock.stackYamlLocalPkgsOverlay

      # Suggested overrides for common problems.
      final.dhall-haskell-stacklock.suggestedOverlay

      # Any additional overrides you may want to add.
      (hfinal: hprev: {
        # bounds in cabal file are too strict for vector, but it is only used in the tests
        lens = final.haskell.lib.compose.dontCheck hprev.lens;

        # The test suite attempts to run the binaries built in this package
        # through $PATH but they aren't in $PATH
        dhall-lsp-server = final.haskell.lib.compose.dontCheck hprev.dhall-lsp-server;
      })
    ];
  });

  dhall-haskell-packages = final.symlinkJoin {
    name = "dhall-haskell-packages";
    paths = final.dhall-haskell-stacklock.localPkgsSelector final.dhall-haskell-pkg-set;
  };

  dhall-haskell-dev-shell = final.dhall-haskell-pkg-set.shellFor {
    packages = haskPkgs:
      let doCheckAllPkgs = pkgList: map final.haskell.lib.compose.doCheck pkgList;
      in
      # Some of the dhall packages have their tests disabled, but they need to
      # be enabled when building the dev shell so that the dev shell gets _all_
      # the tests deps that are used.
      doCheckAllPkgs (final.dhall-haskell-stacklock.localPkgsSelector haskPkgs);

    # Additional packages that should be available for development.
    nativeBuildInputs = [
      final.cabal-install
      final.ghcid
      final.stack
      final.haskell.packages.ghc8107.haskell-language-server
    ];
  };
}
