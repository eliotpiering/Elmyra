module Audio exposing (..)

import Html exposing (Html)
import Html.Events as Events
import Html.Attributes as Attr
import Json.Decode as JD exposing (Decoder)
import MyModels
import ApiHelpers


type alias Model =
    MyModels.SongModel


type Msg
    = NextSong

streamPath : Int -> String
streamPath id =
    ApiHelpers.apiEndpoint ++ "stream/" ++ (toString id)


view : Model -> Html Msg
view model =
    Html.div [ Attr.id "audio-view-container" ]
        [ currentSongInfo model
        , Html.br [] []
        , htmlAudio model.id
        ]


htmlAudio : Int -> Html Msg
htmlAudio id =
    Html.audio
        [ Attr.src (streamPath id)
        , Attr.type_ "audio/mp3"
        , Attr.controls True
        , Attr.autoplay True
        , Events.on "ended" (JD.succeed NextSong)
        ]
        []


currentSongInfo : Model -> Html Msg
currentSongInfo model =
    Html.table []
        [ Html.thead []
            [ Html.tr []
                [ tableHeaderItem "Artist"
                , tableHeaderItem "Album"
                , tableHeaderItem "Song"
                ]
            ]
        , Html.tbody []
            [ Html.tr []
                [ tableItem model.artist
                , tableItem model.album
                , tableItem model.title
                ]
            ]
        ]


tableItem : String -> Html msg
tableHeaderItem str =
    Html.th [] [ Html.text str ]


tableHeaderItem : String -> Html msg
tableItem str =
    Html.td [] [ Html.text str ]
