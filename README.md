# MittyBot

MittyBot é um bot para Discord desenvolvido em Elixir usando a biblioteca [Nostrum](https://hexdocs.pm/nostrum), projetado para interagir com várias APIs, como TMDb, QuoteAPI e ValorantAPI. Ele oferece funcionalidades como pesquisa de filmes, citações inspiradoras e detalhes de conta e estatísticas de eSports do jogo Valorant.

## Funcionalidades

- **Busca de Filmes (TMDb)**: Integração com a API do TMDb para pesquisa e detalhes de filmes.
- **Citações (QuoteAPI)**: Retorna citações de diversos filmes, series e jogos.
- **Informações de Conta de Valorant (ValorantAPI)**: Busca dados de conta do Valorant usando uma rota pública da Henrikdev.
- **Estatísticas de eSports do Valorant**: Exibe estatísticas de partidas de eSports de Valorant para a região do Brasil.

## Estrutura do Projeto

- `mitty_bot.ex`: Arquivo principal do bot que gerencia as interações e comandos do Discord.
- `valorantApiService.ex`: Serviço responsável por interagir com a API do Valorant para buscar informações de conta e estatísticas de eSports.
- `tmdbService.ex`: Serviço para fazer requisições à API do TMDb e buscar dados sobre filmes.
- `quoteApiService.ex`: Serviço para buscar citações na API do QuoteAPI e formatá-las.

## Como Executar

### Pré-requisitos
- Elixir instalado
- Biblioteca Nostrum configurada
- Token do bot do Discord

## Exemplos de Uso

MittyBot responde a vários comandos que permitem buscar informações sobre filmes, citações inspiradoras e dados do jogo Valorant. Aqui estão alguns comandos disponíveis:

### Comandos de Filmes e Citações

- **`!director {nome_do_diretor}`**  
  Busca e exibe filmes de um diretor específico.
  - **Exemplo**: `!director Christopher Nolan`
  - **Resposta**: Lista de filmes dirigidos por Christopher Nolan.

- **`!acted {nome_do_ator}`**  
  Exibe filmes nos quais um ator ou atriz específica atuou.
  - **Exemplo**: `!acted Leonardo DiCaprio`
  - **Resposta**: Lista de filmes estrelados por Leonardo DiCaprio.

- **`!cine`**  
  Mostra uma lista de filmes que estão em cartaz nos cinemas.
  - **Exemplo**: `!cine`
  - **Resposta**: Lista dos filmes mais recentes em exibição.

- **`!quote`**  
  Fornece uma citação aleatória de um filme ou uma frase inspiradora.
  - **Exemplo**: `!quote`
  - **Resposta**: Uma citação de filme com o autor, ou "Autor desconhecido" se o autor não estiver disponível.

### Comandos de Valorant

- **`!player {nome_do_jogador}`**  
  Mostra informações de um jogador de Valorant usando seu nome e tag.
  - **Exemplo**: `!player username#tag`
  - **Resposta**: Detalhes da conta do jogador, incluindo nível e estatísticas principais.

- **`!Esports`**  
  Exibe estatísticas e informações de eSports de Valorant para partidas da região do Brasil.
  - **Exemplo**: `!Esports`
  - **Resposta**: Dados sobre partidas recentes e estatísticas de eSports do Valorant.



### Passo a Passo
1. Clone o repositório:
   ```bash
   git clone https://github.com/seu-usuario/MittyBot.git
   cd MittyBot
