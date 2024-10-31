defmodule MittyBot.Services.ValorantApiServices do
  @moduledoc """
  Serviço para buscar informações de jogadores e eventos de eSports na API do Valorant.
  """

  @base_url "https://api.henrikdev.xyz/valorant"
  @api_key "HDEV-32ffff6d-851a-4175-90f8-daa7d99fcddc"

  # Função para buscar informações de um jogador
  def search_player(nickname, tag) do
      url = "#{@base_url}/v1/mmr-history/br/#{URI.encode(nickname)}/#{URI.encode(tag)}?api_key=#{@api_key}"

    options = [
      timeout: 10_000,
      recv_timeout: 10_000
    ]


    case HTTPoison.get(url, [], options) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          # Verifica se existe dados
          {:ok, %{"data" => player_data}} ->
            IO.puts("Dados do jogador encontrados: #{inspect(player_data)}")
            {:ok, player_data}

          {:error, decode_error} ->
            IO.puts("Erro ao decodificar JSON: #{inspect(decode_error)}")
            {:error, {:decoding_failed, decode_error}}
        end

      {:ok, %{status_code: 404}} ->
        {:error, :player_not_found}

      {:error, request_error} ->
        {:error, {:request_failed, request_error}}
    end
  end

  # Função para buscar dados de eSports
  def search_esports do
    url = "#{@base_url}/v1/esports/schedule?region=brazil&api_key=#{@api_key}"
    options = [timeout: 10_000, recv_timeout: 10_000]

    IO.puts("Buscando dados de eSports em URL: #{url}")

    case HTTPoison.get(url, [], options) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"data" => schedule_data}} when is_list(schedule_data) ->
            formatted_data =
              Enum.map(schedule_data, fn match ->
                format_match(match)
              end)
              |> Enum.take(4)  # Limite para 4 partidas

            message = Enum.join(formatted_data, "\n\n---\n\n")
            {:ok, message}

          {:ok, _} -> {:error, :unexpected_format}
          {:error, err} -> {:error, {:decode_error, err}}
        end
    end
  end

  # Formata cada partida individualmente
  defp format_match(match) do
    """
    **Data**: #{match["date"]}
    **Estado**: #{match["state"]}
    **Liga**: #{get_in(match, ["league", "name"])} (#{get_in(match, ["league", "region"])})
    **Equipes**:
    #{format_teams(match["match"]["teams"])}
    **VOD**: #{match["vod"] || "No VOD available"}
    """
  end

  # Formata as equipes envolvidas na partida
  defp format_teams(teams) when is_list(teams) do
    teams
    |> Enum.map(fn team ->
      """
      Name: #{team["name"]}
      Code: #{team["code"]}
      Wins: #{get_in(team, ["record", "wins"])}
      Losses: #{get_in(team, ["record", "losses"])}
      """
    end)
    |> Enum.join("\n---\n")
  end
end
