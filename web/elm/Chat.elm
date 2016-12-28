module Chat exposing (..)

import Html exposing (Html)
import Html.Events as Events
import Html.Attributes as Attr
import Json.Encode as JE
import Json.Decode as JD


type alias ChatModel =
    { messages : List String
    , newMessage : String
    }


initialModel : ChatModel
initialModel =
    { messages = [ "hello this is a message" ], newMessage = "" }


type Msg
    = SendMessage
    | ReceiveMessage JE.Value
    | SetNewMessage String


type ChatCmd
    = PushMessage String
    | None


chatMessageDecoder : JD.Decoder String
chatMessageDecoder =
    (JD.field "body" JD.string)


update : Msg -> ChatModel -> ( ChatModel, ChatCmd )
update action model =
    case action of
        SendMessage ->
            ( { model | newMessage = "" }, PushMessage model.newMessage )

        ReceiveMessage raw ->
            case JD.decodeValue chatMessageDecoder raw of
                Ok chatMessage ->
                    ( { model | messages = chatMessage :: model.messages }
                    , None
                    )

                Err error ->
                    ( model, None )

        SetNewMessage str ->
            ( { model | newMessage = str }, None )


view : ChatModel -> Html Msg
view model =
    Html.div [ Attr.id "chat-container" ]
        [ newMessageForm model
        , Html.ul []
            (List.map
                (\message ->
                    Html.li [] [ Html.text message ]
                )
                model.messages
            )
        ]


newMessageForm : ChatModel -> Html Msg
newMessageForm model =
    Html.form [ Events.onSubmit SendMessage ]
        [ Html.input [ Attr.type_ "text", Attr.value model.newMessage, Events.onInput SetNewMessage ] []
        ]
