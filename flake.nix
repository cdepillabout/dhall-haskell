{
  description = "Example of using stacklock2nix to build Dhall";

  inputs.stacklock2nix.url = "github:cdepillabout/stacklock2nix/main";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs, stacklock2nix }:
    let
      # System types to support.
      supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor =
        forAllSystems (system: import nixpkgs { inherit system; overlays = [ stacklock2nix.overlay self.overlay ]; });
    in
    {
      # A Nixpkgs overlay.
      overlay = import nix/overlay.nix;

      packages = forAllSystems (system: {
        dhall-haskell-packages = nixpkgsFor.${system}.dhall-haskell-packages;
      });

      defaultPackage = forAllSystems (system: self.packages.${system}.dhall-haskell-packages);

      devShells = forAllSystems (system: {
        dhall-haskell-dev-shell = nixpkgsFor.${system}.dhall-haskell-dev-shell;
      });

      devShell = forAllSystems (system: self.devShells.${system}.dhall-haskell-dev-shell);
    };
}
