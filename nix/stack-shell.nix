
{
  # This is the ghc that stack passes in, but we just ignore it.
  ghc
, ...
}:

with (import ./. {});

haskell.lib.compose.buildStackProject {
  name = "dhall-haskell-stack-shell";
  # Make sure to use the GHC that is used to build our Haskell package set.
  ghc = dhall-haskell-pkg-set.ghc;
  # Example native build inputs that are for building with stack.
  nativeBuildInputs = [ libsodium ncurses zlib ];
}
