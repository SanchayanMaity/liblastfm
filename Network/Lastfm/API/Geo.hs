module Network.Lastfm.API.Geo
  ( getEvents, getMetroArtistChart, getMetroHypeArtistChart, getMetroHypeTrackChart
  , getMetroTrackChart, getMetroUniqueArtistChart, getMetroUniqueTrackChart
  , getMetroWeeklyChartlist, getMetros, getTopArtists, getTopTracks
  ) where

import Network.Lastfm.Core
import Network.Lastfm.Types ( (?<), APIKey, Country, Distance, From, Latitude
                            , Limit, Location, Longitude, Metro, Page, To
                            )

getEvents :: Maybe Latitude
          -> Maybe Longitude
          -> Maybe Location
          -> Maybe Distance
          -> Maybe Limit
          -> Maybe Page
          -> APIKey
          -> Lastfm Response
getEvents latitude longitude location distance limit page apiKey = dispatch $ callAPI "geo.getEvents"
  [ "lat" ?< latitude
  , "long" ?< longitude
  , "location" ?< location
  , "distance" ?< distance
  , "limit" ?< limit
  , "page" ?< page
  , "api_key" ?< apiKey
  ]

getMetroArtistChart :: Country -> Metro -> Maybe From -> Maybe To -> APIKey -> Lastfm Response
getMetroArtistChart = getMetroChart "geo.getMetroArtistChart"

getMetroHypeArtistChart :: Country -> Metro -> Maybe From -> Maybe To -> APIKey -> Lastfm Response
getMetroHypeArtistChart = getMetroChart "geo.getMetroHypeArtistChart"

getMetroHypeTrackChart :: Country -> Metro -> Maybe From -> Maybe To -> APIKey -> Lastfm Response
getMetroHypeTrackChart = getMetroChart "geo.getMetroHypeTrackChart"

getMetroTrackChart :: Country -> Metro -> Maybe From -> Maybe To -> APIKey -> Lastfm Response
getMetroTrackChart = getMetroChart "geo.getMetroTrackChart"

getMetroUniqueArtistChart :: Country -> Metro -> Maybe From -> Maybe To -> APIKey -> Lastfm Response
getMetroUniqueArtistChart = getMetroChart "geo.getMetroUniqueArtistChart"

getMetroUniqueTrackChart :: Country -> Metro -> Maybe From -> Maybe To -> APIKey -> Lastfm Response
getMetroUniqueTrackChart = getMetroChart "geo.getMetroUniqueTrackChart"

getMetroWeeklyChartlist :: Metro -> APIKey -> Lastfm Response
getMetroWeeklyChartlist metro apiKey = dispatch $ callAPI "geo.getMetroWeeklyChartlist"
  [ "metro" ?< metro
  , "api_key" ?< apiKey
  ]

getMetros :: Country -> APIKey -> Lastfm Response
getMetros country apiKey = dispatch $ callAPI "geo.getMetros"
  [ "country" ?< country
  , "api_key" ?< apiKey
  ]

getTopArtists :: Country -> Maybe Limit -> Maybe Page -> APIKey -> Lastfm Response
getTopArtists country limit page apiKey = dispatch $ callAPI "geo.getTopArtists"
  [ "country" ?< country
  , "limit" ?< limit
  , "page" ?< page
  , "api_key" ?< apiKey
  ]

getTopTracks :: Country -> Maybe Location -> Maybe Limit -> Maybe Page -> APIKey -> Lastfm Response
getTopTracks country location limit page apiKey = dispatch $ callAPI "geo.getTopTracks"
  [ "country" ?< country
  , "location" ?< location
  , "limit" ?< limit
  , "page" ?< page
  , "api_key" ?< apiKey
  ]

getMetroChart :: String -> Country -> Metro -> Maybe From -> Maybe To -> APIKey -> Lastfm Response
getMetroChart method country metro from to apiKey = dispatch $ callAPI method
  [ "country" ?< country
  , "metro" ?< metro
  , "start" ?< from
  , "end" ?< to
  , "api_key" ?< apiKey
  ]