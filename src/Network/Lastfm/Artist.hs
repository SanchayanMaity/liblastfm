{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE UnicodeSyntax #-}
-- | Lastfm artist API
--
-- This module is intended to be imported qualified:
--
-- @
-- import qualified Network.Lastfm.Artist as Artist
-- @
module Network.Lastfm.Artist
  ( addTags, getCorrection, getEvents, getInfo, getPastEvents, getPodcast
  , getShouts, getSimilar, getTags, getTopAlbums, getTopFans, getTopTags
  , getTopTracks, removeTag, search, share, shout
  ) where

import Data.Monoid ((<>))

import Network.Lastfm.Request


-- | Tag an artist with one or more user supplied tags.
--
-- <http://www.last.fm/api/show/artist.addTags>
addTags ∷ Artist → [Tag] → Request RequireSign f
addTags ar ts = api "artist.addTags" <> artist ar <> tags ts <> post


-- | Use the last.fm corrections data to check whether the supplied artist has a correction to a canonical artist
--
-- <http://www.last.fm/api/show/artist.getCorrection>
getCorrection ∷ Artist → Request Ready f
getCorrection ar = api "artist.getCorrection" <> artist ar


-- | Get a list of upcoming events for this artist. Easily integratable into calendars, using the ical standard (see feeds section below).
--
-- Optional: either 'mbid' or 'artist'; 'autocorrect', 'limit', 'pages', 'festivalsonly'
--
-- <http://www.last.fm/api/show/artist.getEvents>
getEvents ∷ Request Ready f
getEvents = api "artist.getEvents"


-- | Get the metadata for an artist. Includes biography.
--
-- Optional: either 'mbid' or 'artist'; 'lang', 'autocorrect', 'username'
--
-- <http://www.last.fm/api/show/artist.getInfo>
getInfo ∷ Request Ready f
getInfo = api "artist.getInfo"


-- | Get a paginated list of all the events this artist has played at in the past.
--
-- Optional: either 'mbid' or 'artist'; 'page', 'autocorrect', 'limit'
--
-- <http://www.last.fm/api/show/artist.getPastEvents>
getPastEvents ∷ Request Ready f
getPastEvents = api "artist.getPastEvents"


-- | Get a podcast of free mp3s based on an artist
--
-- Optional: either 'mbid' or 'artist'; 'autocorrect'
--
-- <http://www.last.fm/api/show/artist.getPodcast>
getPodcast ∷ Request Ready f
getPodcast = api "artist.getPodcast"


-- | Get shouts for this artist. Also available as an rss feed.
--
-- Optional: either 'mbid' or 'artist'; 'autocorrect', 'limit', 'page'
--
-- <http://www.last.fm/api/show/artist.getShouts>
getShouts ∷ Request Ready f
getShouts = api "artist.getShouts"


-- | Get all the artists similar to this artist
--
-- Optional: either 'mbid' or 'artist'; 'limit', 'autocorrect'
--
-- <http://www.last.fm/api/show/artist.getSimilar>
getSimilar ∷ Request Ready f
getSimilar = api "artist.getSimilar"


-- | Get the tags applied by an individual user to an artist on Last.fm. If accessed as an authenticated service /and/ you don't supply a user parameter then this service will return tags for the authenticated user. To retrieve the list of top tags applied to an artist by all users use artist.getTopTags.
--
-- Optional: either 'mbid' or 'artist'; 'user', 'autocorrect'
--
-- <http://www.last.fm/api/show/artist.getTags>
getTags ∷ Request a f
getTags = api "artist.getTags"


-- | Get the top albums for an artist on Last.fm, ordered by popularity.
--
-- Optional: either 'mbid' or 'artist'; 'autocorrect', 'page', 'limit'
--
-- <http://www.last.fm/api/show/artist.getTopAlbums>
getTopAlbums ∷ Request Ready f
getTopAlbums = api "artist.getTopAlbums"


-- | Get the top fans for an artist on Last.fm, based on listening data.
--
-- Optional: either 'mbid' or 'artist'; 'autocorrect'
--
-- <http://www.last.fm/api/show/artist.getTopFans>
getTopFans ∷ Request Ready f
getTopFans = api "artist.getTopFans"


-- | Get the top tags for an artist on Last.fm, ordered by popularity.
--
-- Optional: 'mbid' or 'artist'; 'autocorrect'
--
-- <http://www.last.fm/api/show/artist.getTopTags>
getTopTags ∷ Request Ready f
getTopTags = api "artist.getTopTags"


-- | Get the top tracks by an artist on Last.fm, ordered by popularity
--
-- Optional: either 'mbid' or 'artist'; 'autocorrect', 'page', 'limit'
--
-- <http://www.last.fm/api/show/artist.getTopTracks>
getTopTracks ∷ Request Ready f
getTopTracks = api "artist.getTopTracks"


-- | Remove a user's tag from an artist.
--
-- <http://www.last.fm/api/show/artist.removeTag>
removeTag ∷ Artist → Tag → Request RequireSign f
removeTag ar t = api "artist.removeTag" <> artist ar <> tag t <> post


-- | Search for an artist by name. Returns artist matches sorted by relevance.
--
-- Optional: 'limit', 'page'
--
-- <http://www.last.fm/api/show/artist.search>
search ∷ Artist → Request Ready f
search ar = api "artist.search" <> artist ar


-- | Share an artist with Last.fm users or other friends.
--
-- Optional: 'message', 'public'
--
-- <http://www.last.fm/api/show/artist.share>
share ∷ Artist → Recipient → Request RequireSign f
share ar r = api "artist.share" <> artist ar <> recipient r <> post


-- | Shout in this artist's shoutbox
--
-- <http://www.last.fm/api/show/artist.shout>
shout ∷ Artist → Message → Request RequireSign f
shout ar m = api "artist.shout" <> artist ar <> message m <> post