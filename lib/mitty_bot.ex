defmodule MittyBot do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias MittyBot.Services.TmdbService
  alias MittyBot.Services.QuoteApiService
  alias MittyBot.Services.ValorantApiServices

  @spec handle_event(any()) ::
          :ignore
          | :noop
          | {:error, map()}
          | {:ok, Nostrum.Struct.Message.t()}

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case msg.content do
      "!hi" ->
        Api.create_message(msg.channel_id, "Hello!")

      "!diretor " <> director_name ->
        handle_director_command(msg.channel_id, director_name)

      "!acted " <> actor_name ->
        handle_actor_command(msg.channel_id, actor_name)

      "!cine" ->
        handle_movies_in_theater(msg.channel_id)

      "!quote" ->
        handle_movies_quotes(msg.channel_id)

      "!player " <> player_data ->
        handle_player(player_data, msg.channel_id)

      "!Esports" ->
        handle_esports(msg.channel_id)

      _ ->
        :ignore
    end
  end

  defp handle_director_command(channel_id, director_name) do
    case TmdbService.search_director(director_name) do
      {:ok, movies} ->
        response = format_movie(movies)
        Api.create_message(channel_id, response)

      {:error, _} ->
        Api.create_message(channel_id, "Não consegui encontrar #{director_name} :sob:")
    end
  end

  defp handle_actor_command(channel_id, actor_name) do
    case TmdbService.search_actor(actor_name) do
      {:ok, movies} ->
        response = format_movie(movies)
        Api.create_message(channel_id, response)

      {:error, _} ->
        Api.create_message(channel_id, "Não consegui achar #{actor_name} :sob:")
    end
  end

  defp handle_movies_in_theater(channel_id) do
    case TmdbService.movies_on_theaters() do
      {:ok, movies} ->
        response = format_movie(movies)
        Api.create_message(channel_id, response)

      {:error, _} ->
        Api.create_message(channel_id, "Erro ao buscar filmes em cartaz :sob:")
    end
  end

  defp handle_movies_quotes(channel_id) do
    case QuoteApiService.quote_movie() do
      {:ok, %{"Quotes" => [%{"quote" => quote, "author" => author}]}} ->
        response = "#{quote} — #{author}"
        Api.create_message(channel_id, response)

      {:error, _} ->
        Api.create_message(channel_id, "Erro ao buscar uma citação :sob:")
    end
  end

  defp handle_player(player_data, channel_id) do
    case String.split(player_data, "#") do
      [nickname, tag] ->
        case ValorantApiServices.search_player(nickname, tag) do
          {:ok, player_info} ->
            response = format_player(player_info)
            Api.create_message(channel_id, response)

          {:error, :player_not_found} ->
            Api.create_message(channel_id, "Não consegui encontrar o jogador #{nickname} :sob:")

          {:error, _} ->
            Api.create_message(
              channel_id,
              "Erro ao buscar informações do jogador #{nickname} :sob:"
            )
        end

      _ ->
        Api.create_message(channel_id, "Formato de jogador inválido. Use: !player nickname#tag")
    end
  end

  # Atualização da função de formatação para exibir detalhes da conta do jogador
  defp format_player(%{
         "name" => name,
         "tag" => tag,
         "region" => region,
         "card" => card,
         "title" => title,
         "updated_at" => updated_at
       }) do
    """
    Informações do jogador:
    ```
    Nome: #{name}##{tag}
    Região: #{region}
    Título: #{title || "Nenhum título"}
    Card: #{card || "Nenhum card"}
    Última atualização: #{updated_at}
    ```
    """
  end

  # Caso a resposta não contenha os dados esperados
  defp format_player(_), do: "Informações de jogador não disponíveis ou em formato inválido."

  defp format_movie([]), do: "Nenhum filme encontrado."

  defp handle_esports(channel_id) do
    IO.puts("Chamando a função search_esports")

    case ValorantApiServices.search_esports() do
      {:ok, message} ->
        IO.puts("Dados de eSports recebidos com sucesso.")
        send_message_in_parts(channel_id, message)

      {:error, reason} ->
        IO.puts("Erro ao buscar dados de eSports: #{inspect(reason)}")
        Api.create_message(channel_id, "Erro ao buscar o cronograma de eSports: #{inspect(reason)}")
    end
  end

  defp send_message_in_parts(channel_id, message) do
    # Divide a mensagem em partes de até 2000 caracteres
    message
    |> String.split_at(2000)
    |> Tuple.to_list()
    |> Enum.each(fn part ->
      Api.create_message(channel_id, part)
      :timer.sleep(500)  # Atraso de 500ms para evitar limites de rate
    end)
  end


  defp format_movie(movies) do
    movies
    |> Enum.map(fn movie -> "#{movie["title"]} - Lançamento: #{movie["release_date"]}" end)
    |> Enum.join("\n")
  end
end
