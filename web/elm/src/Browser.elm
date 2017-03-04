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
import Array exposing (Array)
import BrowserTreeHelpers


type
    Msg
    -- = ItemMsg String Item.Msg
    = Reset
    | UpdateSongs ItemDictionary
    | MouseEnter
    | MouseLeave
    | ToggleSelected TreeLocation
    | ToggleExpanded TreeLocation
    | GroupBy String
    | Up



-- | StartingUpload
-- | Upload


type BrowserCmd
    = OpenGroup ItemModel
    | AddItemToQueue ItemModel
    | ChangeRoute Route
      -- | SendUpload
    | None


initialItemTree : ItemTree SongTag GroupTag
initialItemTree =
    let
        stubs =
            [ SongNode { id = 1, artist = "artist", album = "album", title = "song 1", location = [ 0, 0 ], isSelected = True }
            , SongNode { id = 2, artist = "artist", album = "album", title = "song 2", location = [ 0, 1 ], isSelected = False }
            , GroupNode { name = "group2", isExpanded = False, location = [ 0, 2 ], isSelected = True }
                (Array.fromList
                    [ SongNode { id = 4, artist = "artist", album = "album", title = "song 4", location = [ 0, 2, 0 ], isSelected = False }
                    , SongNode { id = 5, artist = "artist", album = "album", title = "song 5", location = [ 0, 2, 1 ], isSelected = False }
                    ]
                )
            ]
    in
        GroupNode { name = " group 1", isExpanded = True, location = [ 0 ], isSelected = False } (Array.fromList stubs)


initialModel : BrowserModel
initialModel =
    { isMouseOver = False, items = initialItemTree, isUploading = False }


update : Msg -> Bool -> BrowserModel -> ( BrowserModel, BrowserCmd )
update msg isShiftDown model =
    case msg of
        -- ItemMsg id msg ->
        --     case Dict.get id model.items of
        --         Just item ->
        --             let
        --                 ( item_, itemCmd ) =
        --                     Item.update msg item
        --                 model_ =
        --                     { model | items = Dict.insert id item_ model.items }
        --             in
        --                 case itemCmd of
        --                     Item.DoubleClicked ->
        --                         case item_.tags of
        --                             Group groupModel ->
        --                                 ( model_, OpenGroup item_ )
        --                             Song _ ->
        --                                 ( model_, AddItemToQueue item_ )
        --                     Item.Clicked ->
        --                         if isShiftDown then
        --                             ( model_, None )
        --                         else
        --                             let
        --                                 cleanItems =
        --                                     resetItems model.items
        --                                 itemsWithOneSelected =
        --                                     Dict.insert id item_ cleanItems
        --                             in
        --                                 ( { model | items = itemsWithOneSelected }, None )
        --                     Item.AddToQueue ->
        --                         ( model_, AddItemToQueue item_ )
        --                     Item.None ->
        --                         ( model_, None )
        --         Nothing ->
        --             ( model, None )
        Reset ->
            -- ( { model | items = resetItems model.items }, None )
            ( model, None )

        Up ->
            ( model, None )

        -- let
        --     oldId =
        --         model.items
        --             |> Dict.toList
        --             |> List.filter (Tuple.second >> .isSelected)
        --             |> List.map (Tuple.first)
        --             |> List.head
        --             |> Maybe.withDefault "-1"
        -- in
        --     ( { model | items = resetItems model.items }, None )
        UpdateSongs itemModels ->
            ( model, None )

        -- ( { model | items = itemModels }, None )
        MouseEnter ->
            ( { model | isMouseOver = True }, None )

        MouseLeave ->
            ( { model | isMouseOver = False }, None )

        ToggleSelected location ->
            let
                newTree =
                    BrowserTreeHelpers.treeMap
                        (\node ->
                            case node of
                                SongNode tags ->
                                    if location == tags.location then
                                        SongNode { tags | isSelected = not tags.isSelected }
                                    else
                                        node

                                GroupNode tags arr ->
                                    if location == tags.location then
                                        GroupNode { tags | isSelected = not tags.isSelected } arr
                                    else
                                        node
                        )
                        model.items
            in
                ( { model | items = newTree }, None )

        ToggleExpanded location ->
            let
                newTree =
                    BrowserTreeHelpers.treeMap
                        (\node ->
                            case node of
                                GroupNode tags arr ->
                                    if location == tags.location then
                                        GroupNode { tags | isExpanded = not tags.isExpanded } arr
                                    else
                                        node
                                songNode ->
                                  songNode
                        )
                        model.items
            in
                ( { model | items = newTree }, None )


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



-- StartingUpload ->
--     ( { model | isUploading = True }, None )
-- Upload ->
--     ( model, SendUpload )


resetItems : ItemDictionary -> ItemDictionary
resetItems =
    Dict.map (\id item -> Item.update Item.Reset item |> Tuple.first)


view : BrowserModel -> Html Msg
view model =
    Html.div
        [ Attr.id "file-view-container" ]
        [ navigationView model
        , Html.ol
            [ Attr.class "scroll-box"
            , Attr.id "browser-list"
            , Events.onMouseEnter MouseEnter
            , Events.onMouseLeave MouseLeave
            , MyStyle.mouseOver model.isMouseOver
            ]
            [ treeView model.items ]
        ]


treeView : ItemTree SongTag GroupTag -> Html Msg
treeView tree =
    case tree of
        SongNode tags ->
            Html.li
                [ MyStyle.isSelected tags.isSelected
                , Events.onClick <| ToggleSelected tags.location
                ]
                [ Html.text tags.title ]

        GroupNode tags arr ->
            if tags.isExpanded then
                Html.div
                    []
                    [ Html.span
                        [ MyStyle.isSelected tags.isSelected
                        , Events.onClick <| ToggleSelected tags.location
                        , Events.onDoubleClick <| ToggleExpanded tags.location
                        ]
                        [ Html.text tags.name ]
                    , Html.ol
                        []
                        (List.map treeView (Array.toList arr))
                    ]
            else
                Html.li
                    [ MyStyle.isSelected tags.isSelected
                    , Events.onClick <| ToggleSelected tags.location
                    , Events.onDoubleClick <| ToggleExpanded tags.location
                    ]
                    [ Html.text tags.name ]



--     [ navigationView model
--     , Html.ul
--         [ Attr.class "scroll-box"
--         , Attr.id "browser-list"
--         , Events.onMouseEnter MouseEnter
--         , Events.onMouseLeave MouseLeave
--         , MyStyle.mouseOver model.isMouseOver
--         ]
--         (List.map itemToHtml <| SortSongs.byGroupTitle <| Dict.toList model.items)
--     ]
-- itemToHtml : ( String, ItemModel ) -> Html Msg
-- itemToHtml ( id, item ) =
--     Html.map (ItemMsg id) (Item.view id item)


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
                  -- , Events.on "change"
                  --     (JD.succeed StartingUpload)
                ]
                []
            ]
          -- , (if model.isUploading then
          --     Html.li [ Events.onClick Upload ] [ Html.text "Start Upload" ]
          --    else
          -- , Html.text ""
          -- )
        ]
