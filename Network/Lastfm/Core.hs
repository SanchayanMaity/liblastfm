{-# LANGUAGE FlexibleInstances, OverlappingInstances #-}
module Network.Lastfm.Core
  ( Response
  , withSecret
  , firstInnerTagContent, allInnerTagsContent, getAllInnerTags
  , LastfmValue(..), (?<), (?<<), callAPI, callAPI_, optional
  ) where

import Codec.Binary.UTF8.String (decodeString)
import Control.Applicative ((<$>))
import Control.Arrow (second)
import Control.Monad (liftM)
import Data.Digest.Pure.MD5 (md5)
import Data.Function (on)
import Data.IORef
import Data.List (intercalate, sortBy)
import Data.Maybe (fromJust, isJust)
import Data.URLEncoded (urlEncode, export)
import Network.Curl hiding (Content)
import System.IO.Unsafe (unsafePerformIO)
import Text.XML.Light

import qualified Data.ByteString.Lazy.Char8 as BS

type Key = String
type Value = String
type Secret = String
type Sign = String
type Method = String

newtype Response = Response {unwrap :: [Element]}

secret :: IORef Secret
secret = unsafePerformIO $ newIORef ""

withSecret :: Secret -> IO a -> IO a
withSecret s f = writeIORef secret s >> f

class LastfmValue a where
  unpack :: a -> String

instance LastfmValue Int where
  unpack = show
instance LastfmValue [Char] where
  unpack = id
instance LastfmValue a => LastfmValue [a] where
  unpack = intercalate "," . map unpack

(?<) :: LastfmValue a => String -> a -> (String, String)
a ?< b = (a, unpack b)

(?<<) :: LastfmValue a => String -> Maybe a -> (String, Maybe String)
a ?<< b = (a, liftM unpack b)

callAPI :: Method -> [(Key, Value)] -> IO Response
callAPI m as = withCurlDo $ do
                 s <- readIORef secret
                 handle <- initialize
                 response <- liftM (Response . onlyElems . parseXML . decodeString . respBody)
                              (do_curl_ handle
                                        "http://ws.audioscrobbler.com/2.0/?"
                                        [ CurlPostFields . map (export . urlEncode) $ (("api_sig", sign s) : bs) ]
                                        :: IO CurlResponse)
                 reset handle
                 case firstInnerTagContent "error" response of
                   Just e  -> error e
                   Nothing -> return response
  where bs :: [(Key, Value)]
        bs = ("method", m) : as
        sign :: Secret -> Sign
        -- ^ Each API call (a little exception for getToken) should be signed.
        -- Algorithm description can be found at http://www.lastfm.ru/api/authspec Section 8
        sign s = show . md5 . BS.pack . (++ s) . concatMap (uncurry (++)) . sortBy (compare `on` fst) $ bs

callAPI_ :: Method -> [(Key, Value)] -> IO ()
callAPI_ m as = callAPI m as >> return ()

optional :: [(Key, Maybe a)] -> [(Key, a)]
optional = map (second fromJust) . filter (isJust . snd)

firstInnerTagContent :: String -> Response -> Maybe String
firstInnerTagContent tag response = liftM strContent (maybeHead . unwrap . getAllInnerTags tag $ response)
  where maybeHead :: [a] -> Maybe a
        maybeHead [] = Nothing
        maybeHead xs = Just $ head xs

allInnerTagsContent :: String -> Response -> [String]
allInnerTagsContent tag = map strContent <$> unwrap . getAllInnerTags tag

getAllInnerTags ::  String -> Response -> Response
getAllInnerTags tag = Response . concatMap (findElements . unqual $ tag) . unwrap
