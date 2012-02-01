{-# LANGUAGE GeneralizedNewtypeDeriving #-}
module Network.Lastfm.Tasteometer
  ( Value(..), Limit(..), User(..)
  , compare
  ) where

import Data.List (intercalate)
import Data.Maybe (fromMaybe)
import Network.Lastfm.Artist
import Network.Lastfm.Auth (APIKey)
import Network.Lastfm.Core
import Network.Lastfm.User
import Prelude hiding (compare)

data Value = ValueUser User
           | ValueArtists [Artist]

instance Show Value where
  show (ValueUser _)    = "user"
  show (ValueArtists _) = "artists"

instance LastfmValue Value where
  unpack (ValueUser u)     = unpack u
  unpack (ValueArtists as) = unpack as

newtype Limit = Limit Int deriving (Show, LastfmValue)

compare :: Value -> Value -> Maybe Limit -> APIKey -> Lastfm Response
compare value1 value2 limit apiKey = callAPI "tasteometer.compare"
  [ "type1" ?< type1
  , "type2" ?< type2
  , "value1" ?< value1
  , "value2" ?< value2
  , "limit" ?< limit
  , "api_key" ?< apiKey
  ]
  where type1 = show value1
        type2 = show value2

{- `compareGroup' method is deprecated -}
