module QueueItem exposing (..)

import Html exposing (Html)
import Html.Events as Events
import Html.Attributes as Attr
import MyModels exposing (..)
import MyStyle exposing (..)
import FontAwesome as FA
import Color


type Msg
    = ItemClicked
    | ItemDoubleClicked
    | Reset
    | Remove
    | ShiftUp
    | ShiftDown


type QueueItemCmd
    = DoubleClicked
    | Clicked
    | RemoveItem
    | ShiftItemUp
    | ShiftItemDown
    | None


update : Msg -> QueueItemModel -> ( QueueItemModel, QueueItemCmd )
update msg model =
    case msg of
        ItemClicked ->
            ( { model | isSelected = not model.isSelected }, Clicked )

        ItemDoubleClicked ->
            ( model, DoubleClicked )

        Reset ->
            ( { model | isSelected = False }, None )

        Remove ->
            ( model, RemoveItem )

        ShiftUp ->
            ( model, ShiftItemUp )

        ShiftDown ->
            ( model, ShiftItemDown )


view : Bool -> String -> QueueItemModel -> Html Msg
view isCurrentSong id model =
    Html.li
        [ Attr.class "queue-item"
        , MyStyle.currentSong isCurrentSong
        , Events.onDoubleClick ItemDoubleClicked
        , MyStyle.mouseOver model.isMouseOver
        , if model.isSelected then
            Attr.class "selected"
          else
            Attr.class "not-selected"
        ]
        [ (if model.isSelected then
            selectedOptionsHtml model
           else
            Html.p [] [ Html.text "" ]
          )
        , Html.div
            [ Events.onMouseDown ItemClicked
            , Attr.class "queue-item-title"
            ]
            [ Html.text (model.song.title ++ " - " ++ model.song.artist) ]
        ]


selectedOptionsHtml model =
    Html.p
        [ Attr.class "queue-item-option" ]
        [ Html.span [ Events.onClick Remove ] [ FA.arrow_left Color.white 25 ]
        , Html.span [ Events.onClick ShiftDown ] [ FA.arrow_down Color.white 25 ]
        , Html.span [ Events.onClick ShiftUp ] [ FA.arrow_up Color.white 25 ]
        ]
