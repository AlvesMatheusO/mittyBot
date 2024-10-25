defmodule MittyBot.Services.QuoteApiService do
  @moduledoc """
  Serviço para buscar informações na API do QuoteAPI
  https://quoteapi.pythonanywhere.com/.
  """

  @base_url "https://quoteapi.pythonanywhere.com/random"

  def quote_movie do
    case HTTPoison.get(@base_url) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} ->
            {:ok, data}

          {:error, decode_error} ->
            {:error, {:decoding_failed, decode_error}}
        end

      {:ok, %{status_code: status_code}} ->
        {:error, {:unexpected_status, status_code}}

      {:error, request_error} ->
        {:error, {:request_failed, request_error}}
    end
  end
end
