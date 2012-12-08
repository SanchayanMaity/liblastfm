{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE UnicodeSyntax #-}
module Chart (noauth) where

import Data.Aeson.Types
import Network.Lastfm
import Network.Lastfm.Chart
import Test.HUnit

import Common


noauth ∷ [Test]
noauth =
  [ TestLabel "Chart.getHypedArtists" $ TestCase testGetHypedArtists
  , TestLabel "Chart.getHypedTracks" $ TestCase testGetHypedTracks
  , TestLabel "Chart.getLovedTracks" $ TestCase testGetLovedTracks
  , TestLabel "Chart.getTopArtists" $ TestCase testGetTopArtists
  , TestLabel "Chart.getTopTags" $ TestCase testGetTopTags
  , TestLabel "Chart.getTopTracks" $ TestCase testGetTopTracks
  ]
 where
  ak = "29effec263316a1f8a97f753caaa83e0"

  testGetHypedArtists = check ga $
    getHypedArtists <> limit 3 <> apiKey ak

  testGetHypedTracks = check gt $
    getHypedTracks <> limit 2 <> apiKey ak

  testGetLovedTracks = check gt $
    getLovedTracks <> limit 3 <> apiKey ak

  testGetTopArtists = check ga $
    getTopArtists <> limit 4 <> apiKey ak

  testGetTopTags = check gta $
    getTopTags <> limit 5 <> apiKey ak

  testGetTopTracks = check gt $
    getTopTracks <> limit 2 <> apiKey ak


ga, gt, gta ∷ Value → Parser [String]
ga o = parseJSON o >>= (.: "artists") >>= (.: "artist") >>= mapM (.: "name")
gt o = parseJSON o >>= (.: "tracks") >>= (.: "track") >>= mapM (.: "name")
gta o = parseJSON o >>= (.: "tags") >>= (.: "tag") >>= mapM (.: "name")
