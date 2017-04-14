module Main exposing (..)

import Html exposing (Html)
import Html.Attributes as Attr
import Http
import Array exposing (Array)
import Port
import Keyboard
import MyModels exposing (..)
import Queue
import Browser
import Chat
import Helpers
import ApiHelpers
import Phoenix.Socket as Socket exposing (Socket)
import Phoenix.Channel
import Phoenix.Push
import Json.Encode as JE
import SortSongs


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    let
        ( socket, socketCmd ) =
            initialSocket
    in
        ( initialModel socket, Cmd.map PhoenixMsg socketCmd )


type alias Model =
    { browser : BrowserModel
    , queue : QueueModel
    , chat : Chat.ChatModel
    , albumArt : String
    , isShiftDown : Bool
    , socket : Socket Msg
    }


initialModel : Socket Msg -> Model
initialModel socket =
    { queue = { currentSong = 0, array = Array.empty, mouseOver = False, mouseOverItem = 1 }
    , browser = Browser.initialModel
    , chat = Chat.initialModel
    , albumArt = "nothing"
    , isShiftDown = False
    , socket = socket
    }


initialSocket : ( Socket Msg, Cmd (Socket.Msg Msg) )
initialSocket =
    -- TODO is there a better way to join two channels at one time?
    let
        ( socketMsg, socketCmd ) =
            Socket.init socketServer
                |> Socket.withDebug
                |> Socket.on "new:msg" "room:lobby" ReceiveChatMessage
                |> Socket.on "next_song" "queue:lobby" ReceiveNextSong
                |> Socket.on "previous_song" "queue:lobby" ReceivePreviousSong
                |> Socket.on "add_songs" "queue:lobby" ReceiveAddSongs
                |> Socket.on "remove_song" "queue:lobby" ReceiveRemoveSong
                |> Socket.on "swap_songs" "queue:lobby" ReceiveSwapSongs
                |> Socket.on "change_current_song" "queue:lobby" ReceiveChangeCurrentSong
                |> Socket.on "sync" "queue:lobby" ReceiveSync
                |> Socket.join chatChannel

        ( socketMsg_, socketCmd_ ) =
            Socket.join queueChannel socketMsg

        push_ =
            Phoenix.Push.init "sync" "queue:lobby"

        ( socketMsg__, socketCmd__ ) =
            Socket.push push_ socketMsg_
    in
        ( socketMsg__, Cmd.batch [ socketCmd__, socketCmd_, socketCmd ] )


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


chatChannel : Phoenix.Channel.Channel msg
chatChannel =
    Phoenix.Channel.init "room:lobby"


queueChannel : Phoenix.Channel.Channel msg
queueChannel =
    Phoenix.Channel.init "queue:lobby"



-- UPDATE


type Msg
    = QueueMsg Queue.Msg
    | BrowserMsg Browser.Msg
    | ChatMsg Chat.Msg
    | UpdateSongs (Result Http.Error (List SongModel))
    | AddSongToQueue (Result Http.Error SongModel)
    | AddSongsToQueue (Result Http.Error (List SongModel))
    | OpenSongsInBrowser (Result Http.Error (List SongModel))
    | UpdateGroups (Result Http.Error (List GroupModel))
    | KeyUp Keyboard.KeyCode
    | KeyDown Keyboard.KeyCode
    | UpdateAlbumArt String
    | PhoenixMsg (Socket.Msg Msg)
    | ReceiveChatMessage JE.Value
    | ReceiveNextSong JE.Value
    | SendNextSong
    | ReceivePreviousSong JE.Value
    | SendPreviousSong
    | ReceiveAddSongs JE.Value
    | SendAddSongs (List SongModel)
    | ReceiveRemoveSong JE.Value
    | SendRemoveSong Int
    | ReceiveSync JE.Value
    | ReceiveSwapSongs JE.Value
    | SendSwapSongs Int Int
    | SendChangeCurrentSong Int
    | ReceiveChangeCurrentSong JE.Value


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
        KeyUp keyCode ->
            case keyCode of
                37 ->
                    update (SendPreviousSong) model

                38 ->
                    update (SendNextSong) model

                39 ->
                    let
                        ( browser, browserCmd ) =
                            Browser.update Browser.Up model.isShiftDown model.browser
                    in
                        ( { model | browser = browser }, Cmd.none )

                40 ->
                    -- Down
                    update (SendNextSong) model

                32 ->
                    ( model, Port.pause "null" )

                16 ->
                    ( { model | isShiftDown = False }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        KeyDown keyCode ->
            case keyCode of
                16 ->
                    ( { model | isShiftDown = True }, Cmd.none )

                anythingElse ->
                    ( model, Cmd.none )

        QueueMsg msg ->
            let
                ( queue_, queueCmd ) =
                    Queue.update msg model.queue

                model_ =
                    { model
                        | queue =
                            queue_
                    }
            in
                case queueCmd of
                    Queue.RemoveItem index ->
                        update (SendRemoveSong index) model_

                    Queue.SwapItems ( i1, i2 ) ->
                        update (SendSwapSongs i1 i2) model_

                    Queue.ChangeCurrentSong newIndex ->
                        update (SendChangeCurrentSong newIndex) model_

                    Queue.None ->
                        ( model_
                        , Cmd.none
                        )

        BrowserMsg msg ->
            let
                ( browser_, browserCmd ) =
                    Browser.update msg model.isShiftDown model.browser

                model_ =
                    { model | browser = browser_ }
            in
                case Debug.log "browser cmd" browserCmd of
                    Browser.AddItemToQueue item ->
                        case item.data of
                            Song songModel ->
                                -- TODO this code is repeated
                                let
                                    ( model_, socketCmds ) =
                                        update (SendAddSongs [ songModel ]) model
                                in
                                    ( { model_
                                        | browser = Browser.update Browser.Reset False model_.browser |> Tuple.first
                                      }
                                    , socketCmds
                                    )

                            Group _ ->
                                let
                                    updateGroupCmds =
                                        Cmd.batch (ApiHelpers.fetchSongsFromGroups [ item ] AddSongsToQueue)
                                in
                                    ( model_, updateGroupCmds )

                    Browser.LoadGroup groupType ->
                        case groupType of
                            Browser.Album ->
                                ( model, ApiHelpers.fetchAllAlbums UpdateGroups )

                            Browser.Artist ->
                                ( model, ApiHelpers.fetchAllArtists UpdateGroups )

                            Browser.Song ->
                                ( model, ApiHelpers.fetchAllSongs UpdateSongs )

                    Browser.OpenItem item ->
                        let
                            updateGroupCmds =
                                Cmd.batch (ApiHelpers.fetchSongsFromGroups [ item ] UpdateSongs)
                        in
                            ( model_, updateGroupCmds )

                    Browser.None ->
                        ( model_, Cmd.none )

        ChatMsg msg ->
            let
                ( chat_, chatCmd ) =
                    Chat.update msg model.chat
            in
                case chatCmd of
                    Chat.PushMessage str ->
                        let
                            payload =
                                JE.object [ ( "body", JE.string str ) ]

                            push_ =
                                Phoenix.Push.init "new:msg" "room:lobby"
                                    |> Phoenix.Push.withPayload payload

                            ( socket_, socketCmd ) =
                                Debug.log "socket and cmd are " <| Socket.push push_ model.socket
                        in
                            ( { model
                                | chat = chat_
                                , socket = socket_
                              }
                            , Cmd.map PhoenixMsg socketCmd
                            )

                    Chat.None ->
                        ( { model
                            | chat = chat_
                          }
                        , Cmd.none
                        )

        UpdateSongs (Ok songs) ->
            let
                browser =
                    Browser.initialModel

                browser_ =
                    { browser | items = Helpers.makeSongItemDictionary <| SortSongs.byAlbumAndTrack songs }
            in
                ( { model
                    | browser =
                        browser_
                  }
                , Cmd.none
                )

        UpdateSongs (Err _) ->
            ( model, Cmd.none )

        UpdateGroups (Ok groups) ->
            let
                browser =
                    Browser.initialModel

                browser_ =
                    { browser | items = Helpers.makeGroupItemDictionary groups }
            in
                ( { model
                    | browser =
                        browser_
                  }
                , Cmd.none
                )

        UpdateGroups (Err ok) ->
            ( model, Cmd.none )

        AddSongsToQueue (Ok songs) ->
            let
                sortedSongs =
                    SortSongs.byAlbumAndTrack songs

                ( model_, socketCmds ) =
                    update (SendAddSongs sortedSongs) model
            in
                ( { model_
                    | browser = Browser.update Browser.Reset False model_.browser |> Tuple.first
                  }
                , socketCmds
                )

        AddSongsToQueue (Err _) ->
            ( model, Cmd.none )

        AddSongToQueue (Ok song) ->
            let
                ( model_, socketCmds ) =
                    update (SendAddSongs [ song ]) model
            in
                ( { model_
                    | browser = Browser.update Browser.Reset False model.browser |> Tuple.first
                  }
                , socketCmds
                )

        AddSongToQueue (Err _) ->
            -- TODO delete this
            ( model, Cmd.none )

        OpenSongsInBrowser (Ok songs) ->
            let
                newItems =
                    Helpers.makeSongItemDictionary songs

                ( browser_, browserCmd ) =
                    Browser.update (Browser.UpdateSongs newItems) model.isShiftDown model.browser
            in
                ( { model | browser = browser_ }, Cmd.none )

        OpenSongsInBrowser (Err _) ->
            ( model, Cmd.none )

        UpdateAlbumArt picture ->
            ( { model | albumArt = picture }, Cmd.none )

        PhoenixMsg msg ->
            let
                ( socket_, phxCmd ) =
                    Socket.update msg model.socket
            in
                ( { model | socket = socket_ }
                , Cmd.map PhoenixMsg phxCmd
                )

        ReceiveChatMessage raw ->
            let
                ( chat_, chatCmd ) =
                    Chat.update (Chat.ReceiveMessage raw) model.chat
            in
                ( { model | chat = chat_ }, Cmd.none )

        ReceiveNextSong raw ->
            replaceQueue raw model

        SendNextSong ->
            let
                push_ =
                    Phoenix.Push.init "next_song" "queue:lobby"

                ( socket_, socketCmd ) =
                    Socket.push push_ model.socket
            in
                ( { model | socket = socket_ }, Cmd.map PhoenixMsg socketCmd )

        ReceivePreviousSong raw ->
            replaceQueue raw model

        SendPreviousSong ->
            let
                push_ =
                    Phoenix.Push.init "previous_song" "queue:lobby"

                ( socket_, socketCmd ) =
                    Socket.push push_ model.socket
            in
                ( { model | socket = socket_ }, Cmd.map PhoenixMsg socketCmd )

        ReceiveAddSongs raw ->
            replaceQueue raw model

        SendAddSongs songs ->
            let
                json =
                    songs |> SortSongs.byAlbumAndTrack |> ApiHelpers.songsEncoder

                push_ =
                    Phoenix.Push.init "add_songs" "queue:lobby"
                        |> Phoenix.Push.withPayload json

                ( socket_, socketCmd ) =
                    Socket.push push_ model.socket
            in
                ( { model | socket = socket_ }, Cmd.map PhoenixMsg socketCmd )

        ReceiveRemoveSong raw ->
            replaceQueue raw model

        SendRemoveSong songNumber ->
            let
                payload =
                    JE.object [ ( "body", JE.int songNumber ) ]

                push_ =
                    Phoenix.Push.init "remove_song" "queue:lobby"
                        |> Phoenix.Push.withPayload payload

                ( socket_, socketCmd ) =
                    Socket.push push_ model.socket
            in
                ( { model | socket = socket_ }, Cmd.map PhoenixMsg socketCmd )

        ReceiveSwapSongs raw ->
            replaceQueue raw model

        SendSwapSongs from to ->
            let
                payload =
                    JE.object [ ( "from", JE.int from ), ( "to", JE.int to ) ]

                push_ =
                    Phoenix.Push.init "swap_songs" "queue:lobby"
                        |> Phoenix.Push.withPayload payload

                ( socket_, socketCmd ) =
                    Socket.push push_ model.socket
            in
                ( { model | socket = socket_ }, Cmd.map PhoenixMsg socketCmd )

        ReceiveChangeCurrentSong raw ->
            replaceQueue raw model

        SendChangeCurrentSong newCurrentSong ->
            let
                payload =
                    JE.object [ ( "current_song", JE.int newCurrentSong ) ]

                push_ =
                    Phoenix.Push.init "change_current_song" "queue:lobby"
                        |> Phoenix.Push.withPayload payload

                ( socket_, socketCmd ) =
                    Socket.push push_ model.socket
            in
                ( { model | socket = socket_ }, Cmd.map PhoenixMsg socketCmd )

        ReceiveSync raw ->
            replaceQueue raw model


replaceQueue :
    JE.Value
    -> { a | queue : QueueModel }
    -> ( { a | queue : QueueModel }, Cmd msg )
replaceQueue raw model =
    case ApiHelpers.decodeQueue raw of
        Ok queue ->
            let
                queueItems =
                    Debug.log "queue" <| Helpers.makeSongItemList queue.songs

                ( queue_, queueCmd ) =
                    Queue.update (Queue.Replace queueItems queue.currentSong) model.queue
            in
                ( { model | queue = queue_ }, Cmd.none )

        Err e ->
            let
                blah =
                    Debug.log "hello" e
            in
                ( model, Cmd.none )


currentMouseLocation : Model -> MouseLocation
currentMouseLocation model =
    if model.browser.isMouseOver then
        BrowserWindow
    else if model.queue.mouseOver then
        QueueWindow
    else
        OtherWindow



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.ups KeyUp
        , Keyboard.downs KeyDown
        , Socket.listen model.socket PhoenixMsg
        ]


view : Model -> Html Msg
view model =
    Html.div [ Attr.id "main-container" ]
        [ browserView model
        , queueView model
        , chatView model
        ]


browserView : Model -> Html Msg
browserView model =
    Html.map BrowserMsg (Browser.view model.browser)


queueView : Model -> Html Msg
queueView model =
    Html.map QueueMsg (Queue.view model.queue)


chatView : Model -> Html Msg
chatView model =
    Html.map ChatMsg (Chat.view model.chat)
