module SortSongs exposing (byAlbumAndTrack, byGroupTitle)

import MyModels exposing (..)


byAlbumAndTrack :
    List { a | album : comparable, track : comparable1 }
    -> List { a | album : comparable, track : comparable1 }
byAlbumAndTrack =
    List.sortWith
        (\item1 item2 ->
            case compare item1.album item2.album of
                EQ ->
                    compare item1.track item2.track

                greaterOrLess ->
                    greaterOrLess
        )



-- Only works for items that are groups


byGroupTitle : List ( Int, ItemModel ) -> List ( Int, ItemModel )
byGroupTitle =
    List.sortWith
        (\( _, item1 ) ( _, item2 ) ->
            case item1.data of
                Group g1 ->
                    case item2.data of
                        Group g2 ->
                            compare g1.title g2.title

                        anythingElse ->
                            EQ

                anythingElse ->
                    EQ
        )
