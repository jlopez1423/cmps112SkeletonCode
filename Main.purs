module Main where

import Data.Maybe
import Data.String
import Data.Either

import Data.Coords
import Data.GameItem
import Data.GameState
import Data.GameEnvironment

import Control.Monad.Eff
import Control.Monad.RWS
import Control.Monad.RWS.Class

import Game

import Debug.Trace

import qualified Node.ReadLine as RL

--import qualified Node.Yargs as Y
--import qualified Node.Yargs.Setup as Y
--import qualified Node.Yargs.Applicative as Y

runGame :: forall eff. GameEnvironment -> Eff (console :: RL.Console, trace :: Trace | eff) Unit
runGame env = do
  interface <- RL.createInterface RL.process.stdin RL.process.stdout RL.noCompletion
  RL.setPrompt "> " 2 interface

  let
    lineHandler :: forall eff. GameState -> String -> Eff (console :: RL.Console, trace :: Trace | eff) Unit
    lineHandler currentState input = do
      let result = runRWS (game (split " " input)) env currentState
      foreachE result.log trace
      RL.setLineHandler (lineHandler result.state) interface
      RL.prompt interface
      return unit

  RL.setLineHandler (lineHandler initialGameState) interface
  RL.prompt interface

  return unit

main = runGame env
  where
  env :: GameEnvironment
  env = gameEnvironment "Dylan"
