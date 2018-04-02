module Game
    exposing
        ( GameSummary
        , decodeGameSummary
        , initialSummary
        , viewGame
        )

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode as Decode exposing (Decoder, field)


type alias GameSummary =
    { squares : GridOfSquares
    , scores : Dict String Int
    , bingoStatus : BingoStatus
    }


type alias GridOfSquares =
    List (List Square)


type BingoStatus
    = NoBingo
    | Bingo Player


type alias Square =
    { phrase : String
    , points : Int
    , markedBy : Maybe Player
    }


type alias Player =
    { name : String
    , color : String
    }


initialSummary : GameSummary
initialSummary =
    { squares = []
    , scores = Dict.empty
    , bingoStatus = NoBingo
    }



-- VIEW


{-| Displays the game where:

  - `onClickMsg` is the message to send when a square is clicked
  - `gameSummary` is the current game summary

Example:

    type Msg = SendMark String | ...

    viewGame SendMark gameSummary

-}
viewGame : (String -> msg) -> GameSummary -> Html msg
viewGame onClickMsg gameSummary =
    div [ id "game" ]
        [ viewSquares onClickMsg gameSummary.squares
        , viewGameOver gameSummary.bingoStatus
        ]


viewSquares : (String -> msg) -> GridOfSquares -> Html msg
viewSquares onClickMsg squares =
    div [ id "squares" ]
        (List.map (viewSquaresRow onClickMsg) squares)


viewSquaresRow : (String -> msg) -> List Square -> Html msg
viewSquaresRow onClickMsg squares =
    div [ class "row" ]
        (List.map (viewSquare onClickMsg) squares)


viewSquare : (String -> msg) -> Square -> Html msg
viewSquare onClickMsg square =
    let
        ( name, extraAttributes ) =
            case square.markedBy of
                Just player ->
                    ( player.name
                    , [ style [ ( "background-color", player.color ) ] ]
                    )

                Nothing ->
                    ( "", [ onClick (onClickMsg square.phrase) ] )
    in
    div
        ([ class "square" ] ++ extraAttributes)
        [ span [ class "phrase" ] [ text square.phrase ]
        , span [ class "points" ] [ text (toString square.points) ]
        , span [ class "name" ] [ text name ]
        ]


viewGameOver : BingoStatus -> Html msg
viewGameOver bingoStatus =
    case bingoStatus of
        Bingo player ->
            div [ id "game-over" ]
                [ text (player.name ++ " won!") ]

        NoBingo ->
            text ""



-- DECODERS


decodeGameSummary : Decode.Value -> Result String GameSummary
decodeGameSummary payload =
    Decode.decodeValue gameSummaryDecoder payload


gameSummaryDecoder : Decoder GameSummary
gameSummaryDecoder =
    Decode.map3 GameSummary
        (field "squares" gridOfSquaresDecoder)
        (field "scores" (Decode.dict Decode.int))
        (field "winner" bingoStatusDecoder)


gridOfSquaresDecoder : Decoder GridOfSquares
gridOfSquaresDecoder =
    Decode.list (Decode.list squareDecoder)


squareDecoder : Decoder Square
squareDecoder =
    Decode.map3 Square
        (field "phrase" Decode.string)
        (field "points" Decode.int)
        (field "marked_by" (Decode.nullable playerDecoder))


playerDecoder : Decoder Player
playerDecoder =
    Decode.map2 Player
        (field "name" Decode.string)
        (field "color" Decode.string)


bingoStatusDecoder : Decoder BingoStatus
bingoStatusDecoder =
    let
        winnerDecoder maybeWinner =
            case maybeWinner of
                Just winner ->
                    Decode.succeed (Bingo winner)

                Nothing ->
                    Decode.succeed NoBingo
    in
    Decode.nullable playerDecoder
        |> Decode.andThen winnerDecoder
