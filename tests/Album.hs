{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE UnicodeSyntax #-}
module Album (auth, noauth) where

import Data.Aeson.Types
import Data.Text.Lazy (Text)
import Network.Lastfm
import Network.Lastfm.Album
import Test.HUnit

import Common


auth ∷ Text → Text → Text → [Test]
auth ak sk s =
  [ TestLabel "Album.addTags" $ TestCase testAddTags
  , TestLabel "Album.getTags-authenticated" $ TestCase testGetTagsAuth
  , TestLabel "Album.removeTag" $ TestCase testRemoveTag
  , TestLabel "Album.share" $ TestCase testShare
  ]
 where
  testAddTags = check ok . sign s $
    addTags "Pink Floyd" "The Wall" ["70s", "awesome", "classic"] <> apiKey ak <> sessionKey sk

  testGetTagsAuth = check gt . sign s $
    getTags "Pink Floyd" "The Wall" <> apiKey ak <> sessionKey sk

  testRemoveTag = check ok . sign s $
    removeTag "Pink Floyd" "The Wall" "awesome" <> apiKey ak <> sessionKey sk

  testShare = check ok . sign s $
    share "Jerusalem" "Sleep" "liblastfm" <> message "Just listen!" <> apiKey ak <> sessionKey sk


noauth ∷ [Test]
noauth =
  [ TestLabel "Album.getBuyLinks" $ TestCase testGetBuylinks
  , TestLabel "Album.getBuyLinks_mbid" $ TestCase testGetBuylinks_mbid
  , TestLabel "Album.getInfo" $ TestCase testGetInfo
  , TestLabel "Album.getInfo_mbid" $ TestCase testGetInfo_mbid
  , TestLabel "Album.getShouts" $ TestCase testGetShouts
  , TestLabel "Album.getShouts_mbid" $ TestCase testGetShouts_mbid
  , TestLabel "Album.getTags" $ TestCase testGetTags
  , TestLabel "Album.getTags_mbid" $ TestCase testGetTags_mbid
  , TestLabel "Album.getTopTags" $ TestCase testGetTopTags
  , TestLabel "Album.getTopTags_mbid" $ TestCase testGetTopTags_mbid
  , TestLabel "Album.search" $ TestCase testSearch
  ]
 where
  ak = "29effec263316a1f8a97f753caaa83e0"

  testGetBuylinks = check gbl $
    getBuyLinks "Pink Floyd" "The Wall" "United Kingdom" <> apiKey ak

  testGetBuylinks_mbid = check gbl $
    getBuyLinks_mbid "3a16c04b-922b-35c5-a29b-cbe9111fbe79" "United Kingdom" <> apiKey ak

  testGetInfo = check gi $
    getInfo "Pink Floyd" "The Wall" <> apiKey ak

  testGetInfo_mbid = check gi $
    getInfo_mbid "3a16c04b-922b-35c5-a29b-cbe9111fbe79" <> apiKey ak

  testGetShouts = check gs $
    getShouts "Pink Floyd" "The Wall" <> limit 7 <> apiKey ak

  testGetShouts_mbid = check gs $
    getShouts_mbid "3a16c04b-922b-35c5-a29b-cbe9111fbe79" <> limit 7 <> apiKey ak

  testGetTags = check gt $
    getTags "Pink Floyd" "The Wall" <> user "liblastfm" <> apiKey ak

  testGetTags_mbid = check gt $
    getTags_mbid "3a16c04b-922b-35c5-a29b-cbe9111fbe79" <> user "liblastfm" <> apiKey ak

  testGetTopTags = check gtt $
    getTopTags "Pink Floyd" "The Wall" <> apiKey ak

  testGetTopTags_mbid = check gtt $
    getTopTags_mbid "3a16c04b-922b-35c5-a29b-cbe9111fbe79" <> apiKey ak

  testSearch = check se $
    search "wall" <> limit 5 <> apiKey ak


gbl, gi, gs, gt, gtt, se ∷ Value → Parser [String]
gbl o = parseJSON o >>= (.: "affiliations") >>= (.: "physicals") >>= (.: "affiliation") >>= mapM (.: "supplierName")
gi o = parseJSON o >>= (.: "album") >>= (.: "toptags") >>= (.: "tag") >>= mapM (.: "name")
gs o = parseJSON o >>= (.: "shouts") >>= (.: "shout") >>= mapM (.: "body")
gt o = parseJSON o >>= (.: "tags") >>= (.: "tag") >>= mapM (.: "name")
gtt o = parseJSON o >>= (.: "toptags") >>= (.: "tag") >>= mapM (.: "count")
se o = parseJSON o >>= (.: "results") >>= (.: "albummatches") >>= (.: "album") >>= mapM (.: "name")
