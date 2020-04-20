module Event where

import Prelude

import Control.Monad.Except (runExcept)
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Console (logShow)
import Control.Promise (Promise, fromAff)
import Foreign (F, Foreign, readNumber, readString)
import Foreign.Index ((!))
import Effect.Aff.Compat (mkEffectFn1)
import Effect.Uncurried (EffectFn1)

type Event = { id :: Number, text :: String }

readEvent :: Foreign -> F Event
readEvent value = do
  id <- value ! "id" >>= readNumber
  text <- value ! "text" >>= readString
  pure { id, text }

_handler :: Foreign -> Effect (Promise Unit)
_handler f = do
  logShow $ runExcept $ readEvent f
  liftEffect $ fromAff $ pure unit

handler :: EffectFn1 Foreign (Promise Unit)
handler = mkEffectFn1 _handler
