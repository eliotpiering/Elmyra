module Item exposing (..)

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
    | RightArrow
    | Reset


type ItemCmd
    = DoubleClicked
    | Clicked
    | AddToQueue
    | None


type alias Pos =
    { x : Int, y : Int }


update : Msg -> ItemModel -> ( ItemModel, ItemCmd )
update msg model =
    case msg of
        ItemClicked ->
            ( { model | isSelected = not model.isSelected }, Clicked )

        ItemDoubleClicked ->
            ( model, DoubleClicked )

        Reset ->
            ( { model | isSelected = False }, None )

        RightArrow ->
            ( { model | isSelected = False }, AddToQueue )


view :String -> ItemModel -> Html Msg
view id model =
    if model.isSelected then
        selectedItemHtml id model
    else
        itemHtml id model


selectedItemHtml : String -> ItemModel -> Html Msg
selectedItemHtml id model =
    Html.li
        [ Attr.class "selected group-item"
        -- , Events.onMouseDown ItemClicked
        , Attr.style
            [ ( "background-color", MyStyle.darkGrey )
            , ( "color", "white" )
            , ( "display", "flex" )
            , ( "flex-direction", "row" )
            , ( "justify-content", "space-between" )
            , ( "align-items", "center" )
            ]
        , MyStyle.isSelected True
        ]
        [ itemTitle model
        , selectedOptionsHtml model
        ]


itemTitle model =
    case model.data of
        Song m ->
            itemTitleHtml m.title

        Group m ->
            itemTitleHtml m.title


itemTitleHtml title =
    Html.p
        [ Attr.style
            [ ( "background-color", (darkGrey) )
            ]
        ]
        [ Html.text title ]


selectedOptionsHtml model =
    Html.p
        [ Attr.style
            [ ( "backgroud-color", MyStyle.lightGrey )
            , ( "float", "right" )
            ]
        , Events.onClick RightArrow
        ]
        [ FA.arrow_right Color.black 25
        ]



-- commonHtml model maybeDragPos songModel


itemHtml : String -> ItemModel -> Html Msg
itemHtml id model =
    case model.data of
        Song songModel ->
            Html.li (List.append [ Attr.class "song-item" ] <| commonAttrubutes model) <|
                commonHtml model songModel

        Group groupModel ->
            Html.li (List.append [ Attr.class "group-item", Attr.id <| "group-item-" ++ id ] <| commonAttrubutes model) <|
                commonHtml model groupModel


commonAttrubutes : ItemModel -> List (Html.Attribute Msg)
commonAttrubutes model =
    [ Events.onMouseDown ItemClicked
    , Events.onDoubleClick ItemDoubleClicked
    , MyStyle.isSelected model.isSelected
    , MyStyle.mouseOver model.isMouseOver
    ]


commonHtml : ItemModel -> { a | title : String } -> List (Html Msg)
commonHtml model data =
    [ Html.text data.title
    ]
