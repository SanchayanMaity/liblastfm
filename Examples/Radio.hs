#!/usr/bin/env runhaskell

import Control.Monad ((<=<))

import Network.Lastfm.Core
import Network.Lastfm.Types
import qualified Network.Lastfm.API.Radio as Radio

apiKey = APIKey "b25b959554ed76058ac220b7b2e0a026"

search :: IO ()
search = do response <- Radio.search (Name "dubstep") apiKey
            putStr "Dubstep stations: "
            case response of
              Left e  -> print e
              Right r -> print $ stations r
  where stations = mapM (getContent <=< lookupChild "name") <=< lookupChildren "station" <=< lookupChild "stations"

main :: IO ()
main = do -- getPlaylist (requires authorization)
          search
          -- tune (requires authorization)
