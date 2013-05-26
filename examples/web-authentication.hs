{-# LANGUAGE OverloadedStrings #-}
-- | Web application authentication flow example
--
-- Please remember to substitute __YOUR_API_KEY__,
-- __YOUR_SECRET__ and __YOUR_CALLBACK__ for real values
module Main where

import Control.Monad
import Data.IORef

import Control.Lens
import Control.Lens.Aeson
import Control.Monad.IO.Class (liftIO)
import Happstack.Server

import Network.Lastfm
import Network.Lastfm.Authentication


main :: IO ()
main = do
  sessions <- newIORef []
  simpleHTTP nullConf $ msum
    [ dir "authenticate" $ seeOther (link $ apiKey ak <* callback "__YOUR_CALLBACK__") ""
    , dir "save" $ do
        t <- lookText' "token"
        r <- liftIO . lastfm . sign s $ getSession <*> token t <*> apiKey ak <* json
        case r ^? _Just . key "session" . key "key" . _String of
          Just sk -> liftIO $ modifyIORef' sessions (sk:)
          Nothing -> return ()
        ok "Saved."
    , dir "show" $ liftIO (readIORef sessions) >>= ok . show
    ]
 where
  ak = "__YOUR_API_KEY__"
  s = "__YOUR_SECRET__"
