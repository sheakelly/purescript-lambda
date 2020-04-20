module Main where

import Prelude

import Effect (Effect)
import Effect.Class (liftEffect)
import Control.Promise (Promise, fromAff)

basic :: Effect (Promise String)
basic = do
  liftEffect $ fromAff $ pure "Hello World!"
