{-# LANGUAGE DataKinds #-}
{-# LANGUAGE EmptyDataDecls #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE UnicodeSyntax #-}
-- | liblastfm internals
--
-- You shouldn't need to import this module unless you are doing something interesting.
module Network.Lastfm.Internal
  ( Request(..), Format(..), Auth(..), Ready
  , R(..), wrap, unwrap, Coercing(..), render
    -- * Lenses
  , host, method, query
  ) where

import Control.Applicative
import Data.Monoid

import           Data.Serialize (Serialize(..))
import           Data.ByteString (ByteString)
import           Data.Map.Strict (Map)
import qualified Data.Map.Strict as M
import           Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import           Network.URI (escapeURIChar, isUnreserved)


-- | Coerce requests changing their phantom parameters.
-- Used to ensure right flow of working with liblastfm. If you use it on your own, then
-- you will break abstraction
class Coercing t where
  coerce ∷ t (a ∷ Auth) b → t c d


-- | Lastfm API request data type
--
-- low-level representation
data R (f ∷ Format) (a ∷ Auth) t = R
  { _host   ∷ {-# UNPACK #-} !Text
  , _method ∷ {-# UNPACK #-} !ByteString
  , _query  ∷ !(Map Text Text)
  }

-- | Response format: either JSON or XML
data Format = JSON | XML

-- | Authentication method
data Auth =
    Send -- ^ Public API. Doesn't require anything special besides API key
  | Sign -- ^ Private API. Requires Session key and Secret as well as API key

-- | Indicates that request is ready for sending
data Ready

instance Coercing (R f) where
  coerce R { _host = h, _method = m, _query = q } = R { _host = h, _method = m, _query = q }
  {-# INLINE coerce #-}


-- | Lastfm API request data type
--
-- @a@ is authentication state. Might be 'Send' which indicates
-- that you may send this request already or 'Sign', when request signature
-- isn't computed yet
--
-- @f@ is response format. liblastfm currently supports 'JSON' or 'XML'
newtype Request f a t = Request { unRequest ∷ Dual (Endo (R f a t)) }

instance Coercing (Request f) where
  coerce q = wrap $ coerce . unwrap q . coerce
  {-# INLINE coerce #-}

instance Functor (Request f a) where
  fmap _ = coerce
  {-# INLINE fmap #-}

instance Applicative (Request f a) where
  pure _ = wrap id
  f <*> x = let Request g = coerce f
                Request y = coerce x
            in Request $ g <> y
  {-# INLINE (<*>) #-}


-- | Construct String from request for networking
render ∷ R f a t → String
render R { _host = h, _query = q } =
  T.unpack $ mconcat [h, "?", argie q]
 where
  argie = T.intercalate "&" . M.foldrWithKey (\k v m → T.concat [escape k, "=", escape v] : m) []

  escape = T.concatMap (T.pack . escapeURIChar isUnreserved)


-- | Wrapping to interesting 'Monoid' ('R' -> 'R') instance
wrap ∷ (R f a t → R f a t) → Request f a t
wrap = Request . Dual . Endo
{-# INLINE wrap #-}


-- | Unwrapping from interesting 'Monoid' ('R' -> 'R') instance
unwrap ∷ Request f a t → R f a t → R f a t
unwrap = appEndo . getDual . unRequest
{-# INLINE unwrap #-}


-- Miscellaneous instances

instance Serialize (R f a t) where
  put r = do
    put $ T.encodeUtf8 (_host r)
    put $ _method r
    put $ mapmap T.encodeUtf8 T.encodeUtf8 (_query r)
  get = do
    h ← T.decodeUtf8 <$> get
    m ← get
    q ← mapmap T.decodeUtf8 T.decodeUtf8 <$> get
    return R { _host = h, _method = m, _query = q }

mapmap ∷ (Ord s, Ord t) ⇒ (s → t) → (a → b) → Map s a → Map t b
mapmap f g = M.mapKeys f . M.map g


-- | 'Request' '_host'
host :: Functor f => (Text -> f Text) -> R h a t -> f (R h a t)
host f r@R { _host = h } = (\h' -> r { _host = h' }) <$> f h

-- | 'Request' HTTP '_method'
method :: Functor f => (ByteString -> f ByteString) -> R h a t -> f (R h a t)
method f r@R { _method = m } = (\m' -> r { _method = m' }) <$> f m

-- | 'Request' '_query' string
query :: Functor f => (Map Text Text -> f (Map Text Text)) -> R h a t -> f (R h a t)
query f r@R { _query = q } = (\q' -> r { _query = q' }) <$> f q
