defmodule ImportSongs do

  #TODO test this
  def import(file_name) do
    case File.ls(file_name) do
      {:ok, sub_files} ->
        Enum.map(sub_files,  fn(f) ->
          full_path = Path.join([file_name, f])
          ImportSongs.import(full_path)
        end)
      {:error, :enotdir} ->
        # its a file (hopefully an mp3
        import_song(file_name)

      {:error, error} ->
        #TODO raise exception this shouldn't happen
        IO.inspect(error)
    end
  end

  #private methods
  defp import_song(file_name) do
    {id3_tag, _} = System.cmd("id3info", [file_name])
    id3_tags = String.split(id3_tag, "\n")
    song = Enum.reduce(id3_tags, %{path: file_name}, fn(tag, song) ->
      extract_tag_and_store(tag, song)
    end)

    case song do
      %{title: _, artist: _, album: _} ->
        artist_id = find_or_new_artist(song[:artist])
        album_id = find_or_new_album(song[:album], artist_id)
        find_or_new_song(song, artist_id, album_id)

      _ ->
        #TODO keep track of songs we couldn't parse
        IO.puts("couldn't parse ----- ")
        IO.inspect(song)
    end
  end

  defp find_or_new_artist(artist_name) do
    #TODO figure out why artists imported with ? in name are duplicated,
    #### probably an encoding issue with apostrophes
    repo_artist = Elmira.Repo.get_by(Elmira.Artist, title: artist_name)
    if is_nil repo_artist do
      model = %Elmira.Artist{title: artist_name}
      case Elmira.Repo.insert(model) do
        {:ok, artist} ->
          artist.id
        {:error, _changeset} ->
          #TODO raise error
          IO.puts("couldn't insert #{artist_name}")
      end
    else
      repo_artist.id
    end
  end

  defp find_or_new_album(album_name, artist_id) do
    query = from a in Elmira.Album, where: [title: album_name, artist_id: artist_id]
    repo_album = (Elmira.Repo.all query) |> List.first
    if is_nil repo_album do
      model = %Elmira.Album{title: album_name}
      case Elmira.Repo.insert(model) do
        {:ok, artist} ->
          artist.id
        {:error, _changeset} ->
          #TODO raise error
          IO.puts("couldn't insert #{album_name}")
      end
    else
      repo_album.id
    end
  end

  defp find_or_new_song(song, artist_id, album_id) do
    # year and track could both be nil
    year = song.year || 0
    track = song.track || 0

    query = from s in Elmira.Song, where: [title: song.title, album_id: album_id, artist_id: artist_id]
    repo_song = (Elmira.Repo.all query) |> List.first

    if is_nil repo_song do
      model = %Elmira.Song{title: song.title, path: song.path, year: year, track: track, artist_id: artist_id, album_id: album_id}
      Elmira.Repo.insert(model)
    end
  end

  # Basted off of the output from id3info
  defp extract_tag_and_store("=== TIT2 (Title/songname/content description): " <> title, song) do
    Map.put(song, :title, title)
  end

  defp extract_tag_and_store("=== TYER (Year): " <> year, song) do
    {y, _} = Integer.parse(year)
    Map.put(song, :year, y)
  end

  defp extract_tag_and_store("=== TRCK (Track number/Position in set): " <> track, song) do
    {t, _} = Integer.parse(track)
    Map.put(song, :track, t)
  end

  defp extract_tag_and_store("=== TCON (Content type): " <> genre, song) do
    Map.put(song, :genre, genre)
  end

  defp extract_tag_and_store("=== TPE1 (Lead performer(s)/Soloist(s)): " <> artist, song) do
    Map.put(song, :artist, artist)
  end

  defp extract_tag_and_store("=== TALB (Album/Movie/Show title): " <> album, song) do
    Map.put(song, :album, album)
  end

  defp extract_tag_and_store(_no_match, song) do
    song
  end

end

ImportSongs.import("/home/eliot/Music/")
# ImportSongs.import("/mnt/music/")
