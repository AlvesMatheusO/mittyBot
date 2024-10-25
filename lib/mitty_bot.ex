defmodule MittyBot do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias MittyBot.Services.TmdbService
  alias MittyBot.Services.QuoteApiService

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


  defp format_movie([]), do: "Nenhum filme encontrado."

  defp format_movie(movies) do
    movies
    |> Enum.map(fn movie -> "#{movie["title"]} - Lançamento: #{movie["release_date"]}" end)
    |> Enum.join("\n")
  end
end
