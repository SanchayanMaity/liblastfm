{ haskellPackages ? (import <nixpkgs> {}).haskellPackages }:

haskellPackages.cabal.mkDerivation (self: rec {
  pname = "liblastfm";
  version = "0.5.1";
  src = builtins.filterSource (_: type: type != "unknown") ./.;
  buildDepends = with haskellPackages; [
    aeson cereal cryptoApi httpClient httpClientTls networkUri
    profunctors pureMD5 semigroups text xmlConduit
  ];
  testDepends = with haskellPackages; buildDepends ++ [
    hspec hspecExpectationsLens HUnit lens lensAeson xmlHtmlConduitLens
  ];
  meta = {
    description = "Lastfm API interface";
    license = self.stdenv.lib.licenses.mit;
    platforms = self.ghc.meta.platforms;
  };
})
