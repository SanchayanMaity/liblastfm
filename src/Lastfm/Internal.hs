{-# LANGUAGE CPP #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE KindSignatures #-}
-- | liblastfm internals
--
-- You shouldn't need to import this module unless you are doing something interesting.
module Lastfm.Internal
  ( Request(..)
  , Format(..)
  , Ready
  , Sign
  , R(..)
  , wrap
  , unwrap
  , render
  , coerce
  , absorbQuery
  , indexedWith
  ) where

import           Control.Applicative
import           Data.ByteString (ByteString)
#if __GLASGOW_HASKELL__ < 710
import           Data.Foldable (Foldable(..))
#endif
import           Data.Map.Strict (Map)
import qualified Data.Map.Strict as M
import           Data.Monoid
import           Data.Serialize (Serialize(..))
import           Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
#if __GLASGOW_HASKELL__ < 710
import           Data.Traversable (Traversable(..))
#endif
import           Network.URI (escapeURIChar, isUnreserved)


-- | Lastfm API request data type
--
-- low-level representation
data R (f :: Format) = R
  { _host   :: {-# UNPACK #-} !Text
  , _method :: {-# UNPACK #-} !ByteString
  , _query  :: !(Map Text Text)
  }

-- | Response format: either JSON or XML
data Format = JSON | XML

-- | Request that is ready to be sent
data Ready

-- | Request that requires signing procedure
data Sign


-- | Lastfm API request data type
--
-- @a@ is the authentication state. Can be 'Ready', which means this 'Request' is
-- ready to be sent, or 'Sign', if the request signature hasn't been computed yet
--
-- @f@ is the response format (liblastfm supports both 'JSON' and 'XML')
newtype Request f a = Request { unRequest :: Const (Dual (Endo (R f))) a }

instance Functor (Request f) where
  fmap f (Request x) = Request (fmap f x)

instance Applicative (Request f) where
  pure x = Request (pure x)
  Request f <*> Request x = Request (f <*> x)

instance Foldable (Request f) where
  foldMap _ (Request _) = mempty -- not sure why this instance isn't in base

instance Traversable (Request f) where
  traverse _ (Request (Const x)) = pure (Request (Const x)) -- and that


coerce :: Request f a -> Request f b
coerce (Request (Const x)) = Request (Const x)


-- | Construct String from request for networking
render :: R f -> String
render R { _host = h, _query = q } =
  T.unpack $ mconcat [h, "?", argie q]
 where
  argie = T.intercalate "&" . M.foldrWithKey (\k v m -> T.concat [escape k, "=", escape v] : m) []

  escape = T.concatMap (T.pack . escapeURIChar isUnreserved)


-- | Wrapping to interesting 'Monoid' ('R' -> 'R') instance
wrap :: (R f -> R f) -> Request f a
wrap = Request . Const . Dual . Endo

-- | Unwrapping from interesting 'Monoid' ('R' -> 'R') instance
unwrap :: Request f a -> R f -> R f
unwrap = appEndo . getDual . getConst . unRequest


-- | Absorbing a bunch of queries, useful in batch operations
absorbQuery :: Foldable t => t (Request f b) -> Request f a
absorbQuery rs = wrap $ \r ->
  r { _query = _query r <> foldMap (_query . ($ rempty) . unwrap) rs }

-- | Transforming Request to the "array notation"
indexedWith :: Int -> Request f a -> Request f a
indexedWith n r = r <* wrap (\s ->
  s { _query = M.mapKeys (\k -> k <> "[" <> T.pack (show n) <> "]") (_query s) })

-- | Empty request
rempty :: R f
rempty = R mempty mempty mempty


-- Miscellaneous instances

instance Serialize (R f) where
  put r = do
    put $ T.encodeUtf8 (_host r)
    put $ _method r
    put $ bimap T.encodeUtf8 T.encodeUtf8 (_query r)
  get = do
    h <- T.decodeUtf8 <$> get
    m <- get
    q <- bimap T.decodeUtf8 T.decodeUtf8 <$> get
    return R { _host = h, _method = m, _query = q }

bimap :: Ord t => (s -> t) -> (a -> b) -> Map s a -> Map t b
bimap f g = M.mapKeys f . M.map g
