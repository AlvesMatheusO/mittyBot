defmodule MittyBot do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias MittyBot.Services.TmdbService

  @spec handle_event(any()) ::
          :ignore
          | :noop
          | {:error,
             %{
               response:
                 binary()
                 | %{:code => 1..1_114_111, :message => binary(), optional(:errors) => map()},
               status_code: 1..1_114_111
             }}
          | {:ok, Nostrum.Struct.Message.t()}
  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case msg.content do
      "!hi" ->
        Api.create_message(msg.channel_id, "Hello!")

        #Acessar Diretor
      "!diretor " <> director_name ->
        case TmdbService.search_director(director_name) do
          {:ok, movies} ->
            response = format_movie(movies)
            Api.create_message(msg.channel_id, response)

          {:error, _} ->
            Api.create_message(msg.channel_id, "Não consegui encontrar "<> director_name <> " :sob:")
        end

        "!acted " <> actor_name ->
          case TmdbService.search_actor(actor_name) do
            {:ok, movies} ->
              response = format_movie(movies)
              Api.create_message(msg.channel_id, response)

            {:error, _} ->
               Api.create_message(msg.channel_id, "Não consegui achar " <> actor_name <> " :sob:")

          end
        # Else:
      _ ->
        :ignore
    end
  end

  defp format_movie(movies) do
    movies
    |> Enum.map(fn movie -> movie["title"] end)
    |> Enum.join("\n")
  end
end
