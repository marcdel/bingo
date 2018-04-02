module Presence
    exposing
        ( OnlinePlayer
        , Presences
        , initialPresences
        , syncDiff
        , syncState
        , viewOnlinePlayers
        )

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Decode exposing (Decoder, field)
import Phoenix.Presence


type alias Presences =
    { presenceState : PresenceState
    , onlinePlayers : List OnlinePlayer
    }


type alias OnlinePlayer =
    { name : String
    , color : String
    , online_at : String
    }


type alias PresenceState =
    Phoenix.Presence.PresenceState PresenceMetaData


type alias PresenceDiff =
    Phoenix.Presence.PresenceDiff PresenceMetaData


type alias PresenceMetaData =
    { color : String
    , online_at : String
    }


initialPresences : Presences
initialPresences =
    { presenceState = Dict.empty
    , onlinePlayers = []
    }


syncState : Presences -> Decode.Value -> Result String Presences
syncState presences payload =
    case decodePresenceState payload of
        Ok presenceState ->
            let
                newPresenceState =
                    presences.presenceState
                        |> Phoenix.Presence.syncState presenceState

                newPlayers =
                    toOnlinePlayers newPresenceState
            in
            Ok (Presences newPresenceState newPlayers)

        Err error ->
            Err error


syncDiff : Presences -> Decode.Value -> Result String Presences
syncDiff presences payload =
    case decodePresenceDiff payload of
        Ok presenceDiff ->
            let
                newPresenceState =
                    presences.presenceState
                        |> Phoenix.Presence.syncDiff presenceDiff

                newPlayers =
                    toOnlinePlayers newPresenceState
            in
            Ok (Presences newPresenceState newPlayers)

        Err error ->
            Err error



-- VIEW


viewOnlinePlayers : Dict String Int -> Presences -> Html msg
viewOnlinePlayers scores presences =
    div [ class "panel panel-default" ]
        [ div [ class "panel-heading" ]
            [ text "Who's Playing" ]
        , div [ class "panel-body" ]
            [ ul [ id "players", class "list-group" ]
                (List.map (viewOnlinePlayer scores) presences.onlinePlayers)
            ]
        ]


viewOnlinePlayer : Dict String Int -> OnlinePlayer -> Html msg
viewOnlinePlayer scores player =
    let
        score =
            Maybe.withDefault 0
                (Dict.get player.name scores)
    in
    li [ class "list-group-item" ]
        [ span
            [ class "player-color"
            , style [ ( "background-color", player.color ) ]
            ]
            [ text "" ]
        , span [ class "player-name" ] [ text player.name ]
        , span [ class "player-score" ] [ text (toString score) ]
        ]

{-| 

Example of a `metaWrapper` record:

    { metas = 
        [
            { phx_ref = "eKAtLgf+lM4="
            , payload = { color = "#a4deff", online_at = "1519945937" } 
            }
        ] 
    }

-}

toOnlinePlayers : PresenceState -> List OnlinePlayer
toOnlinePlayers presenceState =
    let
        firstMetaPayload metaWrapper =
            case List.head metaWrapper.metas of
                Just metaData ->
                    metaData.payload

                Nothing ->
                    { color = "", online_at = "" }

        toOnlinePlayer ( name, state ) =
            let
                payload =
                    firstMetaPayload state
            in
            OnlinePlayer name payload.color payload.online_at
    in
    presenceState
        |> Dict.toList
        |> List.map toOnlinePlayer



-- DECODERS


decodePresenceState : Decode.Value -> Result String PresenceState
decodePresenceState payload =
    Decode.decodeValue
        (Phoenix.Presence.presenceStateDecoder metaDataDecoder)
        payload


decodePresenceDiff : Decode.Value -> Result String PresenceDiff
decodePresenceDiff payload =
    Decode.decodeValue
        (Phoenix.Presence.presenceDiffDecoder metaDataDecoder)
        payload


metaDataDecoder : Decoder PresenceMetaData
metaDataDecoder =
    Decode.map2 PresenceMetaData
        (field "color" Decode.string)
        (field "online_at" Decode.string)
