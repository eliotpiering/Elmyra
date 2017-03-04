module ApiHelpers exposing (..)

import Http
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE
import MyModels exposing (..)


apiEndpoint : String
apiEndpoint =
    "http://localhost:4000/api/"


fetchSongsFromArtist id groupAction =
    let
        url =
            apiEndpoint ++ "artists/" ++ (toString id) ++ "/songs"
    in
        Http.send groupAction <|
            Http.get url songsDecoder


fetchSongsFromAlbum id groupAction =
    let
        url =
            apiEndpoint ++ "albums/" ++ (toString id) ++ "/songs"
    in
        Http.send groupAction <|
            Http.get url songsDecoder


fetchSongsFromGroups items groupAction =
    -- TODO ideally this only takes groups and there is a separate path to add songs to a queue
    items
        |> List.map
            (\item ->
                case item.data of
                    Group group ->
                        let
                            url =
                                apiEndpoint ++ group.kind ++ "/" ++ (toString group.id) ++ "/songs"
                        in
                            Http.send groupAction <|
                                Http.get url songsDecoder

                    Song _ ->
                        Cmd.none
            )


fetchAllSongs successAction =
    let
        url =
            apiEndpoint ++ "songs"
    in
        Http.send successAction <|
            Http.get url songsDecoder



-- fetchAllArtists : Msg -> Msg -> Cmd Msg


fetchAllArtists successAction =
    let
        url =
            apiEndpoint ++ "artists"
    in
        Http.send successAction <|
            Http.get url artistsDecoder



-- fetchAllAlbums : Msg -> Msg -> Cmd Msg


fetchAllAlbums successAction =
    let
        url =
            apiEndpoint ++ "albums"
    in
        Http.send successAction <|
            Http.get url albumsDecoder


decodeSongs : JE.Value -> Result String (List SongModel)
decodeSongs raw =
    JD.decodeValue songsDecoder raw


decodeQueue : JE.Value -> Result String { songs : List SongModel, currentSong : Int }
decodeQueue raw =
    JD.decodeValue queueDecoder raw


albumsDecoder : Decoder (List GroupModel)
albumsDecoder =
    JD.field "albums" <| JD.list groupDecoder


artistsDecoder : Decoder (List GroupModel)
artistsDecoder =
    JD.field "artists" <| JD.list groupDecoder


queueDecoder : Decoder { songs : List SongModel, currentSong : Int }
queueDecoder =
    JD.map2 (\songs current -> { songs = songs, currentSong = current }) (JD.field "songs" (JD.list songDecoder)) (JD.field "current_song" JD.int)


songsDecoder : Decoder (List SongModel)
songsDecoder =
    JD.field "songs" <| JD.list songDecoder


songsEncoder : List SongModel -> JE.Value
songsEncoder songs =
    JE.object [ ( "songs", JE.list <| List.map songEncoder songs ) ]


groupDecoder : Decoder GroupModel
groupDecoder =
    JD.map4 GroupModel
        (JD.field "id" JD.int)
        (JD.field "kind" JD.string)
        (JD.field "title" JD.string)
        songsDecoder


songDecoder : Decoder SongModel
songDecoder =
    JD.map6 SongModel
        (JD.field "id" JD.int)
        (JD.field "path" JD.string)
        (JD.field "title" JD.string)
        (JD.field "artist" JD.string)
        (JD.field "album" JD.string)
        (JD.field "track" JD.int)


songEncoder : SongModel -> JE.Value
songEncoder song =
    JE.object
        [ ( "id", JE.int song.id )
        , ( "path", JE.string song.path )
        , ( "title", JE.string song.title )
        , ( "artist", JE.string song.artist )
        , ( "album", JE.string song.album )
        , ( "track", JE.int song.track )
        ]


decodeSync : JE.Value -> Maybe ( Int, List SongModel )
decodeSync raw =
    -- TODO this a stupid way to decode this json that looks like
    --  {"songs": songs, "current_song": int}
    let
        songs =
            decodeSongs raw

        currentSong =
            JD.decodeValue (JD.field "current_song" JD.int) raw
    in
        case songs of
            Ok songs ->
                case currentSong of
                    Ok currentSong ->
                        Just ( currentSong, songs )

                    Err _ ->
                        Nothing

            Err _ ->
                Nothing