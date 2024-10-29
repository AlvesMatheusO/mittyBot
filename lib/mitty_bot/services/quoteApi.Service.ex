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
          {:ok, %{"Quotes" => [%{"quote" => quote, "author" => author}]}} ->
            # Se o autor for "Null" ou não for fornecido, atribua "Autor desconhecido"
            formatted_author = if author in ["Null", nil], do: "Autor desconhecido", else: author
            {:ok, %{"quote" => quote, "author" => formatted_author}}

          {:ok, _unexpected_data} ->
            {:error, :unexpected_response_format}

          {:error, decode_error} ->
            {:error, {:decoding_failed, decode_error}}
        end

      {:ok, %{status_code: status_code}} when status_code != 200 ->
        {:error, {:unexpected_status, status_code}}

      {:error, request_error} ->
        {:error, {:request_failed, request_error}}
    end
  end
end
