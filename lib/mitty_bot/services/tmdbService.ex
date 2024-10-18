defmodule MittyBot.Services.TmdbService do
  @moduledoc """
  Serviço para buscar informações na API do TMDb.
  """

  @api_key "f7809065a7efebbcdb9e0cf29f8f2695"
  @base_url "https://api.themoviedb.org/3"

  def search_director(director_name) do
    url = "#{@base_url}/search/person?api_key=#{@api_key}&query=#{URI.encode(director_name)}"
    fetch_person(url, &get_movies/1)
  end

  def search_actor(actor_name) do
    url = "#{@base_url}/search/person?api_key=#{@api_key}&query=#{URI.encode(actor_name)}"
    fetch_person(url, &get_movies_acted/1)
  end

  defp fetch_person(url, callback) do
    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"results" => [%{"id" => person_id} | _]}} ->
            callback.(person_id)

          _ -> {:error, :falha_json}
        end

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Erro ao buscar pessoa: #{inspect(reason)}")
        {:error, :api_falhou}
    end
  end

  defp get_movies(person_id) do
    url = "#{@base_url}/person/#{person_id}/movie_credits?api_key=#{@api_key}"
    fetch_credits(url, "Director")
  end

  defp get_movies_acted(person_id) do
    url = "#{@base_url}/person/#{person_id}/movie_credits?api_key=#{@api_key}"
    fetch_credits(url, nil)
  end

  defp fetch_credits(url, job) do
    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"crew" => crew}} when job != nil ->
            movies = Enum.filter(crew, &(&1["job"] == job))
            {:ok, movies}

          {:ok, %{"cast" => cast}} ->
            {:ok, cast}

          _ -> {:error, :falha_json}
        end

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Erro ao buscar créditos: #{inspect(reason)}")
        {:error, :api_falhou}
    end
  end

  def movies_on_theaters do
    url = "#{@base_url}/movie/now_playing?api_key=#{@api_key}&language=pt-BR&page=1&region=BR"

    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"results" => movies}} -> {:ok, movies}
          _ -> {:error, :falha_json}
        end

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Erro ao buscar filmes em cartaz: #{inspect(reason)}")
        {:error, :api_falhou}
    end
  end
end
