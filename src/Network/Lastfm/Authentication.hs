{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE UnicodeSyntax #-}
-- | Lastfm authentication procedure helpers
--
-- Basically, lastfm provides 3 ways to authenticate user:
--
--  - web application - <http://www.lastfm.ru/api/webauth>
--
--  - desktop application - <http://www.lastfm.ru/api/desktopauth>
--
--  - modile application - <http://www.lastfm.ru/api/mobileauth>
--
-- Note that you can use any of them in your
-- application despite their names
module Network.Lastfm.Authentication
  ( -- * Helpers
    getToken, getSession, getMobileSession
  , link
  ) where

import Data.Monoid

import Network.Lastfm.Internal
import Network.Lastfm.Request


-- | Get authorization token
getToken ∷ Request Ready f
getToken = api "auth.getToken"
{-# INLINE getToken #-}


-- | Get session key
getMobileSession ∷ Username → Password → Request RequireSign f
getMobileSession u p = api "auth.getMobileSession" <> username u <> password p
{-# INLINE getMobileSession #-}


-- | Get session key
getSession ∷ Token → Request RequireSign f
getSession t = api "auth.getSession" <> token t
{-# INLINE getSession #-}


-- | Construct link user should follow to approve application
link ∷ Request a f → String
link q = render . unwrap q $ R
  { host = "http://www.last.fm/api/auth/"
  , _method = mempty
  , _query = mempty
  , parse = undefined
  }
{-# INLINE link #-}