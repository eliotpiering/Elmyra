module Helpers exposing (makeSongItemDictionary, makeGroupItemDictionary, makeSongItemList, isSong)

import Dict exposing (Dict)
import MyModels exposing (..)


-- Public


makeSongItemList : List SongModel -> List QueueItemModel
makeSongItemList songs =
    songs |> List.map (\s -> { song = s, isSelected = False, isMouseOver = False })


makeSongItemDictionary : List SongModel -> ItemDictionary
makeSongItemDictionary songs =
    makeItemDictionary <| List.map Song songs


makeGroupItemDictionary : List GroupModel -> ItemDictionary
makeGroupItemDictionary groups =
    makeItemDictionary <| List.map Group groups


isSong : ItemModel -> Bool
isSong item =
    case item.data of
        Song _ ->
            True

        _ ->
            False



-- Private


makeItemDictionary : List ItemData -> ItemDictionary
makeItemDictionary itemDatas =
    let
        ids =
            generateIdList (List.length itemDatas) []

        pairs =
            List.map2 (,) ids itemDatas
    in
        List.foldl
            (\( id, itemData ) dict -> Dict.insert id { isSelected = False, isMouseOver = False, data = itemData } dict)
            Dict.empty
            pairs


generateIdList : Int -> List Int -> List Int
generateIdList len list =
    if len == 0 then
        list
    else
        (generateIdList (len - 1) list) ++ [ len ]
