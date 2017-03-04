module Chat exposing (..)

import Html exposing (Html)
import Html.Events as Events
import Html.Attributes as Attr
import Json.Encode as JE
import Json.Decode as JD
import MyStyle


type alias ChatModel =
    { messages : List String
    , newMessage : String
    , isMinimized : Bool
    }


initialModel : ChatModel
initialModel =
    { messages = [], newMessage = "", isMinimized = True }


type Msg
    = SendMessage
    | ReceiveMessage JE.Value
    | SetNewMessage String
    | ToggleMinimize


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

        ToggleMinimize ->
            ( { model | isMinimized = not model.isMinimized }, None )


view : ChatModel -> Html Msg
view model =
    Html.div [
         Attr.id "chat-container",
         Attr.class "scroll-box",
         MyStyle.chatBoxHeight model.isMinimized
        ]
        [ minimizeButon model.isMinimized
        , Html.hr [] []
        , newMessageForm model
        , Html.ul [ Attr.id "chat-message-list" ]
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


minimizeButon : Bool -> Html Msg
minimizeButon isMinimized =
    Html.span [ Events.onClick ToggleMinimize ]
        [ Html.text
            (if isMinimized then
                "+ show chat"
             else
                "- hide chat"
            )
        ]
