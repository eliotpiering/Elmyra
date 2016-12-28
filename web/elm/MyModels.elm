module MyModels exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Phoenix.Socket as Socket exposing (Socket)


type alias SongModel =
    { id : Int
    , path : String
    , title : String
    , artist : String
    , album : String
    , track : Int
    }


type alias GroupModel =
    { id : Int
    , kind : String
    , title : String
    , songs : List SongModel
    }


type alias QueueModel =
    { array : Array QueueItemModel
    , mouseOver : Bool
    , mouseOverItem : Int
    , currentSong : Int
    }


type alias BrowserModel =
    { isMouseOver : Bool
    , items : ItemDictionary
    }


type alias ItemDictionary =
    Dict String ItemModel


type alias QueueItemModel =
    { isSelected : Bool
    , isMouseOver : Bool
    , song : SongModel
    }


type alias ItemModel =
    { isSelected : Bool
    , isMouseOver : Bool
    , data : ItemData
    }


type ItemData
    = Song SongModel
    | Group GroupModel


type MouseLocation
    = BrowserWindow
    | QueueWindow
    | OtherWindow
