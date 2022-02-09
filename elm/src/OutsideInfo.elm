port module OutsideInfo exposing (..)

import Dict exposing (..)
import Json.Decode exposing (..)
import File exposing (File)

port sendMessage : String -> Cmd msg
port messageReceiver : (String -> msg) -> Sub msg

port getArtDisplaySend : Int -> Cmd msg
port getArtDisplayReceiver : (Value -> msg) -> Sub msg

port addArtistSend : String -> Cmd msg
port addArtistReceiver : (Bool -> msg) -> Sub msg

port getArtistSend : String -> Cmd msg
port getArtistReceiver : (Value -> msg) -> Sub msg
port getArtistErrorReceiver : (Value -> msg) -> Sub msg

port getNumArtSend : () -> Cmd msg
port getNumArtReceiver : (Int -> msg) -> Sub msg

port getNumArtistSend : () -> Cmd msg
port getNumArtistReceiver : (Int -> msg) -> Sub msg

port getArtSend : Int -> Cmd msg
port getArtReceiver : (Value -> msg) -> Sub msg

port getFeatureSend : Int -> Cmd msg
port getFeatureReceiver : (Value -> msg) -> Sub msg

port getDisplayFeatureSend : Int -> Cmd msg
port getDisplayFeatureReceiver : (Int -> msg) -> Sub msg

port getBidSend : Int -> Cmd msg
port getBidReceiver : (Value -> msg) -> Sub msg

port modifyArtistProfileSend : (String, String) -> Cmd msg
port modifyArtistProfileReceiver : (Bool -> msg) -> Sub msg

port startArtWithFeatureReceiver : (Bool -> msg) -> Sub msg
port startArtWithFeatureSend : () -> Cmd msg

port startFeatureReceiver : (Bool -> msg) -> Sub msg
port startFeatureSend : (Int, Int) -> Cmd msg

port makeBidReceiver : (Value -> msg) -> Sub msg
port makeBidSend : (Int, String) -> Cmd msg

port nextFeatureReceiver : (Bool -> msg) -> Sub msg
port nextFeatureSend : (Int, Int) -> Cmd msg

port finishArtReceiver : (Bool -> msg) -> Sub msg
port finishArtSend : Int -> Cmd msg

port controlStartArtWithFeatureReceiver : (Bool -> msg) -> Sub msg
port controlStartArtWithFeatureSend : (String, String) -> Cmd msg

port getArtListReceiver : (List Value -> msg) -> Sub msg
port getArtListSend : () -> Cmd msg


port registerArtCreatedListener : (Int -> msg) -> Sub msg
port registerFeatureCreatedListener : (Int -> msg) -> Sub msg
