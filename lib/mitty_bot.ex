defmodule MittyBot do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias MittyBot.Services.TmdbService
  alias MittyBot.Services.QuoteApiService
  alias MittyBot.Services.ValorantApiServices

  @max_message_length 2000



  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case msg.content do
      "!director " <> director_name -> handle_director_command(msg.channel_id, director_name)
      "!acted " <> actor_name -> handle_actor_command(msg.channel_id, actor_name)
      "!cine" -> handle_movies_in_theater(msg.channel_id)
      "!quote" -> handle_movies_quotes(msg.channel_id)
      "!player " <> player_data -> handle_player(player_data, msg.channel_id)
      "!Esports" -> handle_esports(msg.channel_id)
      _ -> :ignore
    end
  end

  defp handle_director_command(channel_id, director_name) do
    case TmdbService.search_director(director_name) do
      {:ok, movies} -> send_message_in_parts(channel_id, format_movie(movies))
      {:error, _} -> Api.create_message(channel_id, "Não consegui encontrar #{director_name} :sob:")
    end
  end

  defp handle_actor_command(channel_id, actor_name) do
    case TmdbService.search_actor(actor_name) do
      {:ok, movies} -> send_message_in_parts(channel_id, format_movie(movies))
      {:error, _} -> Api.create_message(channel_id, "Não consegui achar #{actor_name} :sob:")
    end
  end

  defp handle_movies_in_theater(channel_id) do
    case TmdbService.movies_on_theaters() do
      {:ok, movies} -> send_message_in_parts(channel_id, format_movie(movies))
      {:error, _} -> Api.create_message(channel_id, "Erro ao buscar filmes em cartaz :sob:")
    end
  end

  defp handle_movies_quotes(channel_id) do
    case QuoteApiService.quote_movie() do
      {:ok, %{"quote" => quote, "author" => author}} ->
        send_message_in_parts(channel_id, "#{quote} — #{author}")

      _ -> Api.create_message(channel_id, "Erro desconhecido ao buscar uma citação :sob:")
    end
  end

  defp handle_player(player_data, channel_id) do
    case String.split(player_data, "#") do
      [nickname, tag] ->
        case ValorantApiServices.search_player(nickname, tag) do
          {:ok, data} ->
            send_message_in_parts(channel_id, format_player_history(nickname, tag, data))

          {:error, :player_not_found} ->
            Api.create_message(channel_id, "Não consegui encontrar o jogador #{nickname} :sob:")

          {:error, _} ->
            Api.create_message(channel_id, "Erro ao processar dados do jogador #{nickname} :sob:")
        end

      _ -> Api.create_message(channel_id, "Formato de jogador inválido. Use: !player nickname#tag")
    end
  end

  defp handle_esports(channel_id) do
    IO.puts("Chamando a função search_esports")

    case ValorantApiServices.search_esports() do
      {:ok, message} ->
        IO.puts("Dados de eSports recebidos com sucesso.")
        send_message_in_parts(channel_id, message)

      {:error, reason} ->
        IO.puts("Erro ao buscar dados de eSports: #{inspect(reason)}")
        Api.create_message(channel_id, "Erro ao buscar o cronograma: #{inspect(reason)}")
    end
  end

  defp send_message_in_parts(channel_id, message) do
    message
    |> split_message()
    |> Enum.each(fn part ->
      Api.create_message(channel_id, part)
      :timer.sleep(500) # Atraso para evitar limite de taxa
    end)
  end

  defp split_message(message) do
    # Divide a mensagem em partes de até 2000 caracteres
    message
    |> String.graphemes()
    |> Enum.chunk_every(@max_message_length)
    |> Enum.map(&Enum.join/1)
  end

  defp format_player_history(nickname, tag, data) do
    history =
      data
      |> Enum.map(fn match ->
        tier = Map.get(match, "currenttierpatched", "Tier desconhecido")
        map_name = Map.get(match["map"], "name", "Mapa desconhecido")
        date = Map.get(match, "date", "Data desconhecida")
        elo = Map.get(match, "elo", "N/A")
        mmr_change = Map.get(match, "mmr_change_to_last_game", 0)

        """
        **Mapa:** #{map_name}
        **Data:** #{date}
        **Tier:** #{tier}
        **ELO:** #{elo}
        **Mudança MMR:** #{mmr_change}
        """
      end)
      |> Enum.join("\n\n")

    """
    **Histórico de MMR para #{nickname}##{tag}:**
    #{history}
    """
  end

  defp format_movie([]), do: "Nenhum filme encontrado."

  defp format_movie(movies) do
    movies
    |> Enum.map(fn movie -> "#{movie["title"]} - Lançamento: #{movie["release_date"]}" end)
    |> Enum.join("\n")
  end
end
