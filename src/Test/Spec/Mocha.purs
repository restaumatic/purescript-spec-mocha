module Test.Spec.Mocha (
  runMocha,
  MOCHA()
  ) where

import Prelude

import Data.Newtype (unwrap)
import Effect.Aff (Error, runAff_)
import Test.Spec (Spec, collect)
import Data.Either (either, Either(..))
import Data.Foldable (traverse_)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Test.Spec.Tree (Item(..), Tree(..))

foreign import data MOCHA :: Type

foreign import itAsync
  :: Boolean
  -> String
   -> (Effect Unit
       -> (Error -> Effect Unit)
       -> Effect Unit)
   -> Effect Unit

foreign import itPending
   :: String
   -> Effect Unit

foreign import describe
  :: Boolean
  -> String
  -> Effect Unit
  -> Effect Unit

foreign import afterAsync
  :: String
  -> (Effect Unit
      -> (Error -> Effect Unit)
      -> Effect Unit)
  -> Effect Unit

runMocha
  :: Spec Unit
  -> Effect Unit
runMocha spec = traverse_ register $ unwrap $ collect spec
  where
  register =
    case _ of

      Node (Left groupName) tests ->
        describe false groupName (traverse_ register tests)

      Node (Right afterAction) tests ->
        describe false "" do
          afterAsync "" \onSuccess onError ->
            runAff_ (either onError (const onSuccess)) $
              afterAction unit
          traverse_ register tests

      Leaf name Nothing ->
        itPending name

      Leaf name (Just (Item item)) ->
        itAsync false name \onSuccess onError ->
          runAff_ (either onError (const onSuccess)) $
            item.example (_ $ unit)
