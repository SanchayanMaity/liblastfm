module EPlaylist (common, auth) where

import Control.Monad ((<=<))

import Network.Lastfm.Response
import Network.Lastfm.Types
import qualified Network.Lastfm.API.Playlist as Playlist

import Kludges

addTrack :: APIKey -> SessionKey -> IO ()
addTrack apiKey sessionKey = do response <- Playlist.addTrack (Playlist 10298486) (Artist "Apoptose") (Track "Horizont") apiKey sessionKey
                                case response of
                                  Left e   -> print e
                                  Right () -> return ()

create :: APIKey -> SessionKey -> IO ()
create apiKey sessionKey = do response <- Playlist.create (Just (Title "Awesome playlist")) Nothing apiKey sessionKey
                              case response of
                                Left e   -> print e
                                Right () -> return ()

common :: IO ()
common = return ()

auth :: APIKey -> SessionKey -> IO ()
auth apiKey sessionKey = do addTrack apiKey sessionKey
                            create apiKey sessionKey
