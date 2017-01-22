module Browser exposing (..)

import Html exposing (Html)
import Html.Events as Events
import Html.Attributes as Attr
import MyModels exposing (..)
import MyStyle exposing (..)
import Dict exposing (Dict)
import Item
import SortSongs
import NavigationParser exposing (..)
import Json.Decode as JD


type Msg
    = ItemMsg String Item.Msg
    | Reset
    | UpdateSongs ItemDictionary
    | MouseEnter
    | MouseLeave
    | GroupBy String
    | StartingUpload
    | Upload


type BrowserCmd
    = OpenGroup ItemModel
    | AddItemToQueue ItemModel
    | ChangeRoute Route
    | SendUpload
    | None


initialModel : BrowserModel
initialModel =
    { isMouseOver = False, items = Dict.empty, isUploading = False }


update : Msg -> Bool -> BrowserModel -> ( BrowserModel, BrowserCmd )
update msg isShiftDown model =
    case msg of
        ItemMsg id msg ->
            case Dict.get id model.items of
                Just item ->
                    let
                        ( item_, itemCmd ) =
                            Item.update msg item

                        model_ =
                            { model | items = Dict.insert id item_ model.items }
                    in
                        case itemCmd of
                            Item.DoubleClicked ->
                                 case item_.data of
                                    Group groupModel ->
                                        ( model_, OpenGroup item_ )

                                    Song _ ->
                                        ( model_, AddItemToQueue item_ )

                            Item.Clicked ->
                                if isShiftDown then
                                    ( model_, None )
                                else
                                    let
                                        cleanItems =
                                            resetItems model.items

                                        itemsWithOneSelected =
                                            Dict.insert id item_ cleanItems
                                    in
                                        ( { model | items = itemsWithOneSelected }, None )

                            Item.AddToQueue ->
                                (model_, AddItemToQueue item_)

                            Item.None ->
                                ( model_, None )

                Nothing ->
                    ( model, None )

        Reset ->
            ( { model | items = resetItems model.items }, None )

        UpdateSongs itemModels ->
            ( { model | items = itemModels }, None )

        MouseEnter ->
            ( { model | isMouseOver = True }, None )

        MouseLeave ->
            ( { model | isMouseOver = False }, None )

        GroupBy key ->
            case key of
                "song" ->
                    ( model, ChangeRoute SongsRoute )

                "album" ->
                    ( model, ChangeRoute AlbumsRoute )

                "artist" ->
                    ( model, ChangeRoute ArtistsRoute )

                _ ->
                    ( model, None )

        StartingUpload ->
            ( { model | isUploading = True }, None )

        Upload ->
            ( model, SendUpload )


resetItems : ItemDictionary -> ItemDictionary
resetItems =
    Dict.map (\id item -> Item.update Item.Reset item |> Tuple.first)


view : BrowserModel -> Html Msg
view model =
    Html.div
        [ Attr.id "file-view-container"
        ]
        [ navigationView model
        , Html.ul
            [ Attr.class "scroll-box"
            , Attr.id "browser-list"
            , Events.onMouseEnter MouseEnter
            , Events.onMouseLeave MouseLeave
            , MyStyle.mouseOver model.isMouseOver
            ]
            (List.map itemToHtml  <| SortSongs.byGroupTitle <| Dict.toList model.items)
        ]


itemToHtml : ( String, ItemModel ) -> Html Msg
itemToHtml ( id, item ) =
    Html.map (ItemMsg id) (Item.view id item)


navigationView : BrowserModel -> Html Msg
navigationView model =
    Html.ul [ Attr.id "navigation-view-container" ]
        [ Html.li [ Events.onClick (GroupBy "album") ] [ Html.text "Albums" ]
        , Html.li [ Events.onClick (GroupBy "artist") ] [ Html.text "Artists" ]
        , Html.li [ Events.onClick (GroupBy "song") ] [ Html.text "Songs" ]
        , Html.li []
            [ Html.input
                [ Attr.type_ "file"
                , Attr.id "file-upload"
                , Attr.multiple True
                , Attr.action "/api/upload"
                , Events.on "change"
                    (JD.succeed StartingUpload)
                ]
                []
            ]
        , (if model.isUploading then
            Html.li [ Events.onClick Upload ] [ Html.text "Start Upload" ]
           else
            Html.text ""
          )
        ]
