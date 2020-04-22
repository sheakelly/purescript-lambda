module S3EventSource where

import Prelude
import Control.Monad.Except (throwError, runExcept)
import Effect (Effect)
import Effect.Class (liftEffect)
import Control.Promise (Promise, fromAff)
import Effect.Aff.Compat (mkEffectFn1)
import Effect.Uncurried (EffectFn1)
import Effect.Exception (error)
import Data.Either (Either(..))
import Data.Traversable (traverse)
import Foreign (F, Foreign, MultipleErrors, readString, readArray, unsafeToForeign, renderForeignError)
import Foreign.Index ((!))

readS3Bucket :: Foreign -> F S3Bucket
readS3Bucket value = do
  name <- value ! "name" >>= readString
  arn <- value ! "arn" >>= readString
  pure { name, arn }

readS3EventRecord :: Foreign -> F S3EventRecord
readS3EventRecord value = do
  s3 <- value ! "s3" >>= readS3Bucket
  pure { s3 }

readS3Event :: Foreign -> F S3Event
readS3Event value = do
  records <- value ! "Records" >>= readArray >>= traverse readS3EventRecord
  pure { records }

-- Not including all the fields for now
type S3Bucket
  = { name :: String, arn :: String }

type S3EventRecord
  = { s3 :: S3Bucket }

type S3Event
  = { records :: Array S3EventRecord }

renderForeignErrors :: MultipleErrors -> String
renderForeignErrors e =
  show $ renderForeignError <$> e

handleEvent :: forall a b. Foreign -> (Foreign -> F a) -> (a -> b) -> Effect (Promise Foreign)
handleEvent value reader fn = case (runExcept $ reader value) of
  Right r -> liftEffect $ fromAff $ pure $ unsafeToForeign $ fn r
  Left e -> liftEffect $ fromAff $ throwError $ error $ renderForeignErrors e

handler' :: Foreign -> Effect (Promise Foreign)
handler' event =
  handleEvent event readS3Event
    ( \s3Event ->
        { text: "s3 events: " <> show s3Event.records }
    )

handler :: EffectFn1 Foreign (Promise Foreign)
handler = mkEffectFn1 handler'
