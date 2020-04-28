module RestApi where

import Prelude
import Effect.Aff (Aff, throwError)
import Effect.Class (liftEffect)
import Control.Promise (Promise, fromAff)
import Control.Monad.Except (runExcept)
import Foreign (Foreign, renderForeignError)
import Effect.Aff.Compat (mkEffectFn1)
import Effect.Uncurried (EffectFn1)
import Effect.Console (log)
import Data.Either (Either(..))
import Effect.Exception (error)
import Simple.JSON (class ReadForeign, read, write, class WriteForeign)

runHandler :: forall a b. ReadForeign a => WriteForeign b => (a -> Aff b) -> Foreign -> Aff Foreign
runHandler h event = case read event of
  Right r -> write <$> h r
  Left e -> throwError $ error $ show $ renderForeignErrors e
  where
  renderForeignErrors e = show $ renderForeignError <$> e

mkHandler :: forall a b. ReadForeign a => WriteForeign b => (a -> Aff b) -> EffectFn1 Foreign (Promise Foreign)
mkHandler h = mkEffectFn1 $ fromAff <<< runHandler h

type APIGatewayProxyEvent
  = { path :: String, httpMethod :: String }

type APIGatewayProxyResult
  = { statusCode :: Int, body :: String }

router :: APIGatewayProxyEvent -> String
router { httpMethod: "GET" } = "Get method"

router { httpMethod: "POST" } = "Post method"

router { httpMethod } = "Unsupported method " <> httpMethod

handler' :: APIGatewayProxyEvent -> Aff APIGatewayProxyResult
handler' event = do
  pure { statusCode: 500, body: response }
  where
  response = router event

handler :: EffectFn1 Foreign (Promise Foreign)
handler = mkHandler handler'
