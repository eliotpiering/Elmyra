module BrowserTreeHelpers exposing (..)

import MyModels exposing (..)
import Array exposing (Array)
import List.Extra as ListEx


maybeGetNodeFromLocation : ItemTree a b -> TreeLocation -> Maybe (ItemTree a b)
maybeGetNodeFromLocation tree location =
    -- List foldr : (a -> b -> b) -> b -> List a -> b
    List.foldl
        (\index maybeTree ->
            case maybeTree of
                Just tree ->
                    case tree of
                        GroupNode tags arr ->
                            Array.get index arr

                        songNode ->
                            Just songNode

                Nothing ->
                    Nothing
        )
        (Just tree)
        location


treeMap func tree =
    case tree of
        GroupNode tags arr ->
            let
                newArr =
                    Array.map (treeMap func) arr
            in
                (func (GroupNode tags newArr))

        songNode ->
            (func songNode)


fromSongList : List SongModel -> ItemTree SongTag GroupTag
fromSongList songModels =
    -- groupWhile : (a -> a -> Bool) -> List a -> List (List a)
    let
        groupedSongs =
            ListEx.groupWhile (\x y -> x.artist == y.artist) songModels
    in
        GroupNode { name = "root", isExpanded = True, isSelected = False, location = [] } (toGroupNodeArray groupedSongs)


toGroupNodeArray : List (List SongModel) -> Array (ItemTree SongTag GroupTag)
toGroupNodeArray groups =
    groups
        |> List.indexedMap
            (\i g ->
                let
                    groupName =
                        (List.head g) |> Maybe.andThen (\s -> Just s.artist) |> Maybe.withDefault "no group"
                in
                    GroupNode
                        { name = groupName
                        , isExpanded = False
                        , isSelected = False
                        , location = [i]
                        }
                        (toSongNodeArray i g)
            )
        |> Array.fromList


toSongNodeArray : Int -> List SongModel -> Array (ItemTree SongTag GroupTag)
toSongNodeArray parentI songs =
    songs
        |> List.indexedMap
            (\i s ->
                SongNode
                    { id = s.id
                    , album = s.album
                    , artist = s.artist
                    , title = s.title
                    , isSelected = False
                    , location = [parentI, i]
                    }
            )
        |> Array.fromList
