module Queue exposing (..)

import Html exposing (Html)
import Html.Events as Events
import Html.Attributes as Attr
import MyModels exposing (..)
import MyStyle exposing (..)
import Array exposing (Array)
import Array.Extra
import Audio
import QueueItem
import Json.Encode as JE
import Json.Decode as JD


type Msg
    = MouseEnter
    | MouseLeave
    | QueueItemMsg Int QueueItem.Msg
    | AudioMsg Audio.Msg
    | Drop (List QueueItemModel)
    | Replace (List QueueItemModel) Int
    | Reorder JE.Value
    | Remove JE.Value
    | PreviousSong
    | NextSong


type QueueCmd
    = RemoveItem Int
    | SwapItems ( Int, Int )
    | None


type alias Pos =
    { x : Int, y : Int }


update : Msg -> QueueModel -> ( QueueModel, QueueCmd )
update msg model =
    case msg of
        MouseEnter ->
            ( { model | mouseOver = True }, None )

        MouseLeave ->
            ( { model | mouseOver = False }, None )

        QueueItemMsg id msg ->
            case Array.get id model.array of
                Just song ->
                    let
                        ( song_, queueItemCmd ) =
                            QueueItem.update msg song

                        model_ =
                            { model | array = Array.set id song_ model.array }
                    in
                        case Debug.log "queueItemCmd" queueItemCmd of
                            Just (QueueItem.DoubleClicked) ->
                                ( { model_ | currentSong = id }, None )

                            Just (QueueItem.RemoveItem) ->
                                ( { model_ | array = resetQueue model_.array }, RemoveItem id )

                            Just (QueueItem.Clicked) ->
                                let
                                    newArray =
                                        -- reset the queue and re add the selected song, there is probably a better way to do this
                                        resetQueue model_.array |> Array.set id song_
                                in
                                    ( { model_ | array = newArray }, None )

                            Just (QueueItem.ShiftItemUp) ->
                                if id /= 0 then
                                    ( model_, SwapItems ( id, id - 1 ) )
                                else
                                    ( model_, None )

                            Just (QueueItem.ShiftItemDown) ->
                                if id /= (Array.length model_.array - 1) then
                                    ( model_, SwapItems ( id, id + 1 ) )
                                else
                                    ( model_, None )

                            anythingElse ->
                                ( model_, None )

                Nothing ->
                    ( model, None )

        Drop newSongs ->
            let
                newArrayItems =
                    Array.fromList newSongs
            in
                ( { model | array = resetQueue <| Array.append model.array newArrayItems }, None )

        Replace newSongs currentSong ->
            let
                newArrayItems =
                    Debug.log "array" <| Array.fromList newSongs
            in
                ( { model
                    | array = newArrayItems
                    , currentSong = currentSong
                  }
                , None
                )

        Reorder raw ->
            case JD.decodeValue (JD.map2 (,) (JD.field "from" JD.int) (JD.field "to" JD.int)) raw of
                Ok ( from, to ) ->
                    let
                        array =
                            model.array

                        maybeFromItem =
                            Array.get from array

                        maybeToItem =
                            Array.get to array
                    in
                        case maybeFromItem of
                            Just fromItem ->
                                case maybeToItem of
                                    Just toItem ->
                                        let
                                            array_ =
                                                array
                                                    |> Array.set from toItem
                                                    |> Array.set to fromItem
                                        in
                                            ( { model | array = array_ }, None )

                                    Nothing ->
                                        ( model, None )

                            Nothing ->
                                ( model, None )

                Err _ ->
                    ( model, None )

        -- in
        -- let
        --     currentQueueIndex =
        --         model.currentSong
        --     maybeIndexedItemToReorder =
        --         model.array |> Array.toIndexedList |> List.filter (\( i, song ) -> song.isSelected) |> List.head
        -- in
        --     case maybeIndexedItemToReorder of
        --         Just ( indexOfItemToReorder, itemToReorder ) ->
        --             let
        --                 queueLength =
        --                     Array.length model.array
        --                 itemsToStayTheSame =
        --                     model.array |> Array.filter (not << .isSelected)
        --                 left =
        --                     Array.slice 0 model.mouseOverItem itemsToStayTheSame
        --                 right =
        --                     Array.slice model.mouseOverItem queueLength itemsToStayTheSame
        --                 reorderedQueue =
        --                     Array.append (Array.push itemToReorder left) right
        --                 newQueueIndex =
        --                     if currentQueueIndex > indexOfItemToReorder && currentQueueIndex < model.mouseOverItem then
        --                         currentQueueIndex - 1
        --                     else if currentQueueIndex < indexOfItemToReorder && currentQueueIndex > model.mouseOverItem then
        --                         currentQueueIndex + 1
        --                     else
        --                         currentQueueIndex
        --             in
        --                 ( { model
        --                     | array = resetQueue reorderedQueue
        --                     , currentSong = newQueueIndex
        --                   }
        --                 , None
        --                 )
        --         Nothing ->
        --             ( model, None )
        Remove raw ->
            case JD.decodeValue (JD.field "body" JD.int) raw of
                Ok index ->
                    case Array.get index model.array of
                        Just item ->
                            let
                                newQueueIndex =
                                    if index < model.currentSong then
                                        model.currentSong - 1
                                    else
                                        model.currentSong

                                array_ =
                                    Array.Extra.removeAt index model.array
                            in
                                ( { model
                                    | array = resetQueue array_
                                    , currentSong = newQueueIndex
                                  }
                                , None
                                )

                        Nothing ->
                            ( model, None )

                Err _ ->
                    ( model, None )

        NextSong ->
            ( nextSong model, None )

        PreviousSong ->
            let
                shouldReset =
                    model.currentSong == 0
            in
                if shouldReset then
                    let
                        newCurrentSong =
                            (Array.length model.array - 1)
                    in
                        ( { model
                            | currentSong = newCurrentSong
                          }
                        , None
                        )
                else
                    let
                        newCurrentSong =
                            (model.currentSong - 1)
                    in
                        ( { model
                            | currentSong = newCurrentSong
                          }
                        , None
                        )

        AudioMsg msg ->
            case msg of
                Audio.NextSong ->
                    ( nextSong model, None )


nextSong : QueueModel -> QueueModel
nextSong model =
    let
        shouldReset =
            model.currentSong >= (Array.length model.array) - 1
    in
        if shouldReset then
            { model
                | currentSong = 0
            }
        else
            let
                newCurrentSong =
                    model.currentSong + 1
            in
                { model
                    | currentSong = newCurrentSong
                }


resetQueue : Array QueueItemModel -> Array QueueItemModel
resetQueue =
    Array.map (QueueItem.update QueueItem.Reset >> Tuple.first)


currentSelected : QueueModel -> Maybe Int
currentSelected model =
    model.array
        |> Array.toIndexedList
        |> List.filter (\( index, item ) -> item.isSelected)
        |> List.map Tuple.first
        |> List.head


itemToHtml : Int -> ( Int, QueueItemModel ) -> Html Msg
itemToHtml currentSong ( id, song ) =
    Html.map (QueueItemMsg id) (QueueItem.view (id == currentSong) (toString id) song)


view : QueueModel -> Html Msg
view model =
    Html.div
        [ Attr.id "queue-view-container" ]
        [ audioPlayer <| getMaybeCurrentSong model
        , Html.ul
            [ Attr.class "scroll-box"
            , Attr.id "queue-list"
            , Events.onMouseEnter MouseEnter
            , Events.onMouseLeave MouseLeave
            , MyStyle.mouseOver model.mouseOver
            ]
          <|
            Array.toList <|
                Array.indexedMap
                    ((\id item -> itemToHtml model.currentSong ( id, item )))
                    model.array
        ]


audioPlayer : Maybe SongModel -> Html Msg
audioPlayer maybeSong =
    case maybeSong of
        Just song ->
            Html.map AudioMsg (Audio.view song)

        Nothing ->
            Html.div [ Attr.id "audio-view-container" ] []


getMaybeCurrentSong : QueueModel -> Maybe SongModel
getMaybeCurrentSong model =
    case Array.get model.currentSong model.array of
        Just songItem ->
            Just songItem.song

        Nothing ->
            Nothing
