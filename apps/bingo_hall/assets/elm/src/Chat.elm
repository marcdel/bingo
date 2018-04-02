module Chat
    exposing
        ( ChatMessage
        , decodeChatMessage
        , encodeChatMessage
        , scrollToMessage
        , viewChatMessageForm
        , viewChatMessages
        )

import Dom.Scroll
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)
import Json.Decode as Decode exposing (Decoder, field)
import Json.Encode as Encode
import Task


type alias ChatMessage =
    { name : String
    , body : String
    }



-- VIEW


viewChatMessages : List ChatMessage -> Html msg
viewChatMessages chatMessages =
    div [ class "panel panel-default" ]
        [ div [ class "panel-heading" ] [ text "What's Up" ]
        , div [ class "panel-body" ]
            [ ul
                [ id "messages", class "list-group" ]
                (List.map viewChatMessage (List.reverse chatMessages))
            ]
        ]


viewChatMessage : ChatMessage -> Html msg
viewChatMessage message =
    li [ class "list-group-item" ]
        [ span [ class "chat-message-name" ] [ text message.name ]
        , text ": "
        , span [ class "chat-message-body" ] [ text message.body ]
        ]


{-| Displays the chat message form where:

  - `onSubmitMsg` is the message to send when the form is submitted
  - `onInputMsg` is the message to send when text is input
  - `currentValue` is the pending chat message body

Example:

    type Msg = SendChatMessage | SetChatMessageInput String | ...

    viewChatMessageForm
        SendChatMessage
        SetChatMessageInput
        pendingChatMessageBody

-}
viewChatMessageForm : msg -> (String -> msg) -> String -> Html msg
viewChatMessageForm onSubmitMsg onInputMsg currentValue =
    Html.form [ onSubmit onSubmitMsg ]
        [ div [ class "input-group" ]
            [ input
                [ class "form-control"
                , value currentValue
                , onInput onInputMsg
                ]
                []
            , span [ class "input-group-btn" ]
                [ button
                    [ class "btn btn-primary" ]
                    [ i [ class "fa fa-comment" ] [] ]
                ]
            ]
        ]


{-| Scrolls to the bottom of the chat message list to ensure
that new messages are always displayed, pushing older messages
up out of immediate view.
-}
scrollToMessage : msg -> Cmd msg
scrollToMessage msg =
    Dom.Scroll.toBottom "messages"
        |> Task.attempt (always msg)



-- DECODERS / ENCODERS


decodeChatMessage : Decode.Value -> Result String ChatMessage
decodeChatMessage payload =
    Decode.decodeValue chatMessageDecoder payload


chatMessageDecoder : Decoder ChatMessage
chatMessageDecoder =
    Decode.map2 ChatMessage
        (field "name" Decode.string)
        (field "body" Decode.string)


encodeChatMessage : String -> Encode.Value
encodeChatMessage body =
    Encode.object [ ( "body", Encode.string body ) ]
