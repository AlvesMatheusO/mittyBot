defmodule MittyBot.Services.TmdbService do
  @moduledoc """
  Serviço para buscar diretores na API do TMDb.
  """

  @api_key "f7809065a7efebbcdb9e0cf29f8f2695"

  # Função para buscar o diretor pelo nome e pegar o ID
  def search_director(director_name) do
    url =
      "https://api.themoviedb.org/3/search/person?api_key=#{@api_key}&query=#{URI.encode(director_name)}"

    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          # Pega o primeiro resultado e seu ID
          {:ok, %{"results" => [%{"id" => person_id} | _rest]}} ->
            get_movies(person_id)

          _ ->
            {:error, :falha_json}
        end

      _ ->
        {:error, :api_falhou}
    end
  end

  def search_actor(actor_name) do
    url =
      "https://api.themoviedb.org/3/search/person?api_key=#{@api_key}&query=#{URI.encode(actor_name)}"

    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"results" => [%{"id" => person_id} | _rest]}} ->
            get_movies_acted(person_id)

          _ ->
            {:error, :api_falhou}
        end
    end
  end

  defp get_movies(person_id) do
    url = "https://api.themoviedb.org/3/person/#{person_id}/movie_credits?api_key=#{@api_key}"

    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"crew" => crew}} ->
            moviesDirected = Enum.filter(crew, fn entry -> entry["job"] == "Director" end)
            {:ok, moviesDirected}

          _ ->
            {:error, :falha_json}
        end

      _ ->
        {:error, :api_falhou}
    end
  end

  defp get_movies_acted(person_id) do
    url = "https://api.themoviedb.org/3/person/#{person_id}/movie_credits?api_key=#{@api_key}"

    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"cast" => cast}} ->

            {:ok, cast}

          _ ->
            {:error, :falha_json}
        end

      _ ->
        {:error, :api_falhou}
    end
  end

end
