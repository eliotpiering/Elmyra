module BrowserTreeHelpers exposing (..)

import MyModels exposing (..)
import Array exposing (Array)


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
