{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE UnicodeSyntax #-}
module Group (noauth) where

import Data.Aeson.Types
import Network.Lastfm
import Network.Lastfm.Group
import Test.Framework
import Test.Framework.Providers.HUnit

import Common


noauth ∷ Request JSON APIKey → [Test]
noauth ak =
  [ testCase "Group.getHype" testGetHype
  , testCase "Group.getMembers" testGetMembers
  , testCase "Group.getWeeklyAlbumChart" testGetWeeklyAlbumChart
  , testCase "Group.getWeeklyArtistChart" testGetWeeklyArtistChart
  , testCase "Group.getWeeklyChartList" testGetWeeklyChartList
  , testCase "Group.getWeeklyTrackChart" testGetWeeklyTrackChart
  ]
 where
  g = "People with no social lives that listen to more music than is healthy who are slightly scared of spiders and can never seem to find a pen"

  testGetHype = check gh $
    getHype <*> group g <*> ak

  testGetMembers = check gm $
    getMembers <*> group g <* limit 10 <*> ak

  testGetWeeklyAlbumChart = check ga $
    getWeeklyAlbumChart <*> group g <*> ak

  testGetWeeklyArtistChart = check gar $
    getWeeklyArtistChart <*> group g <*> ak

  testGetWeeklyChartList = check gc $
    getWeeklyChartList <*> group g <*> ak

  testGetWeeklyTrackChart = check gt $
    getWeeklyTrackChart <*> group g <*> ak


ga, gar, gh, gm, gt ∷ Value → Parser [String]
gc ∷ Value → Parser [(String, String)]
ga o = parseJSON o >>= (.: "weeklyalbumchart") >>= (.: "album") >>= mapM (.: "playcount")
gar o = parseJSON o >>= (.: "weeklyartistchart") >>= (.: "artist") >>= mapM (.: "name")
gc o = parseJSON o >>= (.: "weeklychartlist") >>= (.: "chart") >>= mapM (\t → (,) <$> (t .: "from") <*> (t .: "to"))
gh o = parseJSON o >>= (.: "weeklyartistchart") >>= (.: "artist") >>= mapM (.: "mbid")
gm o = parseJSON o >>= (.: "members") >>= (.: "user") >>= mapM (.: "name")
gt o = parseJSON o >>= (.: "weeklytrackchart") >>= (.: "track") >>= mapM (.: "url")
