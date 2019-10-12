{-# LANGUAGE TemplateHaskell     #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE RecordWildCards     #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE TypeOperators       #-}
{-# LANGUAGE DeriveGeneric       #-}

module Diagnostics where

import           System.Exit        (exitFailure, exitSuccess)
import           System.IO          (stderr, hPutStrLn)
import qualified Data.ByteString.Lazy.Char8 as BSL
import           System.Environment (getArgs)
import           Control.Monad      (forM_, mzero, join)
import           Control.Applicative
import           Data.Aeson.AutoType.Alternative
import           Data.Aeson(decode, Value(..), FromJSON(..), ToJSON(..),
                            pairs,
                            (.:), (.:?), (.=), object)
import           Data.Monoid
import           Data.Text (Text)
import qualified GHC.Generics

-- | Workaround for https://github.com/bos/aeson/issues/287.
o .:?? val = fmap join (o .:? val)


data Syncing = Syncing { 
    syncingStatus :: Text,
    syncingReceived :: Double,
    syncingMissing :: [Text],
    syncingExpected :: Double
  } deriving (Show,Eq,GHC.Generics.Generic)


instance FromJSON Syncing where
  parseJSON (Object v) = Syncing <$> v .:   "status" <*> v .:   "received" <*> v .:   "missing" <*> v .:   "expected"
  parseJSON _          = mzero


instance ToJSON Syncing where
  toJSON     (Syncing {..}) = object ["status" .= syncingStatus, "received" .= syncingReceived, "missing" .= syncingMissing, "expected" .= syncingExpected]
  toEncoding (Syncing {..}) = pairs  ("status" .= syncingStatus<>"received" .= syncingReceived<>"missing" .= syncingMissing<>"expected" .= syncingExpected)


data LeadersElt = LeadersElt { 
    leadersEltNextnil :: Double,
    leadersEltListheight :: Double,
    leadersEltVm :: Double,
    leadersEltId :: Text,
    leadersEltListlength :: Double
  } deriving (Show,Eq,GHC.Generics.Generic)


instance FromJSON LeadersElt where
  parseJSON (Object v) = LeadersElt <$> v .:   "nextnil" <*> v .:   "listheight" <*> v .:   "vm" <*> v .:   "id" <*> v .:   "listlength"
  parseJSON _          = mzero


instance ToJSON LeadersElt where
  toJSON     (LeadersElt {..}) = object ["nextnil" .= leadersEltNextnil, "listheight" .= leadersEltListheight, "vm" .= leadersEltVm, "id" .= leadersEltId, "listlength" .= leadersEltListlength]
  toEncoding (LeadersElt {..}) = pairs  ("nextnil" .= leadersEltNextnil<>"listheight" .= leadersEltListheight<>"vm" .= leadersEltVm<>"id" .= leadersEltId<>"listlength" .= leadersEltListlength)


data AuditsElt = AuditsElt { 
    auditsEltOnline :: Bool,
    auditsEltId :: Text
  } deriving (Show,Eq,GHC.Generics.Generic)


instance FromJSON AuditsElt where
  parseJSON (Object v) = AuditsElt <$> v .:   "online" <*> v .:   "id"
  parseJSON _          = mzero


instance ToJSON AuditsElt where
  toJSON     (AuditsElt {..}) = object ["online" .= auditsEltOnline, "id" .= auditsEltId]
  toEncoding (AuditsElt {..}) = pairs  ("online" .= auditsEltOnline<>"id" .= auditsEltId)


data Authset = Authset { 
    authsetLeaders :: [LeadersElt],
    authsetAudits :: [AuditsElt]
  } deriving (Show,Eq,GHC.Generics.Generic)


instance FromJSON Authset where
  parseJSON (Object v) = Authset <$> v .:   "leaders" <*> v .:   "audits"
  parseJSON _          = mzero


instance ToJSON Authset where
  toJSON     (Authset {..}) = object ["leaders" .= authsetLeaders, "audits" .= authsetAudits]
  toEncoding (Authset {..}) = pairs  ("leaders" .= authsetLeaders<>"audits" .= authsetAudits)


data Elections = Elections { 
    electionsInprogress :: Bool
  } deriving (Show,Eq,GHC.Generics.Generic)


instance FromJSON Elections where
  parseJSON (Object v) = Elections <$> v .:   "inprogress"
  parseJSON _          = mzero


instance ToJSON Elections where
  toJSON     (Elections {..}) = object ["inprogress" .= electionsInprogress]
  toEncoding (Elections {..}) = pairs  ("inprogress" .= electionsInprogress)


data TopLevel = TopLevel { 
    topLevelLeaderheight :: Double,
    topLevelCurrentminute :: Double,
    topLevelSyncing :: Syncing,
    topLevelAuthset :: Authset,
    topLevelElections :: Elections,
    topLevelTempbalancehash :: Text,
    topLevelPublickey :: Text,
    topLevelCurrentminuteduration :: Double,
    topLevelBalancehash :: Text,
    topLevelLastblockfromdbstate :: Bool,
    topLevelRole :: Text,
    topLevelName :: Text,
    topLevelId :: Text,
    topLevelCurrentheight :: Double,
    topLevelPreviousminuteduration :: Double
  } deriving (Show,Eq,GHC.Generics.Generic)


instance FromJSON TopLevel where
  parseJSON (Object v) = TopLevel <$> v .:   "leaderheight" <*> v .:   "currentminute" <*> v .:   "syncing" <*> v .:   "authset" <*> v .:   "elections" <*> v .:   "tempbalancehash" <*> v .:   "publickey" <*> v .:   "currentminuteduration" <*> v .:   "balancehash" <*> v .:   "lastblockfromdbstate" <*> v .:   "role" <*> v .:   "name" <*> v .:   "id" <*> v .:   "currentheight" <*> v .:   "previousminuteduration"
  parseJSON _          = mzero


instance ToJSON TopLevel where
  toJSON     (TopLevel {..}) = object ["leaderheight" .= topLevelLeaderheight, "currentminute" .= topLevelCurrentminute, "syncing" .= topLevelSyncing, "authset" .= topLevelAuthset, "elections" .= topLevelElections, "tempbalancehash" .= topLevelTempbalancehash, "publickey" .= topLevelPublickey, "currentminuteduration" .= topLevelCurrentminuteduration, "balancehash" .= topLevelBalancehash, "lastblockfromdbstate" .= topLevelLastblockfromdbstate, "role" .= topLevelRole, "name" .= topLevelName, "id" .= topLevelId, "currentheight" .= topLevelCurrentheight, "previousminuteduration" .= topLevelPreviousminuteduration]
  toEncoding (TopLevel {..}) = pairs  ("leaderheight" .= topLevelLeaderheight<>"currentminute" .= topLevelCurrentminute<>"syncing" .= topLevelSyncing<>"authset" .= topLevelAuthset<>"elections" .= topLevelElections<>"tempbalancehash" .= topLevelTempbalancehash<>"publickey" .= topLevelPublickey<>"currentminuteduration" .= topLevelCurrentminuteduration<>"balancehash" .= topLevelBalancehash<>"lastblockfromdbstate" .= topLevelLastblockfromdbstate<>"role" .= topLevelRole<>"name" .= topLevelName<>"id" .= topLevelId<>"currentheight" .= topLevelCurrentheight<>"previousminuteduration" .= topLevelPreviousminuteduration)




parse :: FilePath -> IO TopLevel
parse filename = do input <- BSL.readFile filename
                    case decode input of
                      Nothing -> fatal $ case (decode input :: Maybe Value) of
                                           Nothing -> "Invalid JSON file: "     ++ filename
                                           Just v  -> "Mismatched JSON value from file: " ++ filename
                      Just r  -> return (r :: TopLevel)
  where
    fatal :: String -> IO a
    fatal msg = do hPutStrLn stderr msg
                   exitFailure

main :: IO ()
main = do
  filenames <- getArgs
  forM_ filenames (\f -> parse f >>= (\p -> p `seq` putStrLn $ "Successfully parsed " ++ f))
  exitSuccess


