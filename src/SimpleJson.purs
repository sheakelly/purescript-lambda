module SimpleJson where

import Prelude

import Control.Monad.Except (throwError)
import Effect (Effect)
import Effect.Class (liftEffect)
import Control.Promise (Promise, fromAff)
import Foreign (Foreign)
import Effect.Aff.Compat (mkEffectFn1)
import Effect.Uncurried (EffectFn1)
import Effect.Exception (error)
import Data.Either (Either(..))
import Simple.JSON (class ReadForeign, read, write)

type Input = { id :: Number, message :: String }

type Output = { text :: String }

withEvent :: forall a. ReadForeign a => Foreign -> (a -> Foreign) -> Effect (Promise Foreign)
withEvent f fn =
  case read f of
    Right (r :: a) ->
      liftEffect $ fromAff $ pure $ fn r
    Left e ->
      liftEffect $ fromAff $ throwError $ error $ show e


handler' :: Foreign -> Effect (Promise Foreign)
handler' f = withEvent f (\(input :: Input)
                            -> write { text: "You said: " <> input.message })

handler :: EffectFn1 Foreign (Promise Foreign)
handler = mkEffectFn1 handler'
