import gleam/int
import gleam/list
import gleam/result
import gleam/string
import sgleam/check

//   Análise do problema: O objetivo do trabalho é gerar a tabela de classificação do Brasileirão.
// Para isso, o usuário passará para o programa uma lista de Strings com os resultados dos jogos
// realizados, cada uma sendo escrito na forma “Anfitrião Gols Visitante Gols” (O nome dos times e
// quantidade de gols não tem o caractere de espaço, pois é ele que divide uma coisa da outra)
// (Nota-se que deve-se tratar os erros de formatação dessas Strings). Com isso, calcula-se se cada
// time teve uma vitória (que gera 3 pontos), derrota (que não gera pontos) ou empate (que gera 1
// ponto), e qual foi seu saldo de gols no jogo. Obtendo essas informações para todos os jogos e
// compilando-as, deve-se criar e devolver para o usuário uma tabela (formatada como uma lista de
// Strings) com as colunas "Nome do time", "Número de pontos", "Número de Vitórias" e "Saldo de
// Gols, ordenando-a a partir do "Número de Pontos" e, em caso de empates, usando os critérios
// "Número de Vitórias", "Saldo de Gols" e "Ordem Alfabética". Porém, a novidade em relação aos
// requisitos é que essa lista de Strings deve ser formatada de forma que as colunas fiquem
// alinhadas. Nesse sentido, todas as Strings devem ter mesmo tamanho, porém esse tamanho não deve
// ser fixo, mas sim determinada pelo conteúdo das Strings.
// 
// Por exemplo, para a entrada
// Sao-Paulo 1 Atletico-MG 2
// Flamengo 2 Palmeiras 1
// Palmeiras 0 Sao-Paulo 0
// Atletico-MG 1 Flamengo 2
// 
// O seu programa deve produzir a saída
// Flamengo 6 2 2
// Atletico-MG 3 1 0
// Palmeiras 1 0 -1
// Sao-Paulo 1 0 -1

//   Projeto dos tipos de dados: Para solucionar o problema, é conveniente criar tipos de dados que
// adequem-se aos requisitos que são apresentados. Dito isso, inicialmente dois deles serão criados
// - um para representar cada resultado de jogo e outro para representar cada linha da tabela de
// classificação. Ademais, uma união chamada Erro será criada com outros dois tipos de dado - o
// código do erro e a linha do erro.

// O resultado de um jogo do Brasileirão. 
pub type Jogo {
  // anf é o nome do time anfitrião que participou do jogo
  // golsAnf é a quantidade de gols que o anfitrião fez
  // vis é o nome do time visitante que participou do jogo
  // golsVis é a quantidade de gols que o visitante fez
  Jogo(anf: String, gols_anf: Int, vis: String, gols_vis: Int)
}

// Uma linha da tabela de classificação do Brasileirão
pub type Linha {
  // time é o nome de um clube esportivo participante do campeonato
  // pts é o número de pontos obtido pelo time
  // vit é o número de vitórias obtidas pelo time
  // sg é o saldo de gols do time (diferença entre gols pró e gols contra)
  Linha(time: String, pts: Int, vit: Int, sg: Int)
}

// O código do erro gerado pela entrada
pub type CodErro {
  // No fim do arquivo é posível ver o significado de cada código 
  Erro01
  Erro02
  Erro03
  Erro04
  Erro05
  Erro06
  Erro07
  Erro08
}

// A linha da entrada que gerou o erro
pub type LinhaErro =
  String

// Uma União que traz uma representação unificada do código do Erro e a linha responsável por ele.
// Detalhe: Se você chama a função mensagem_erro(Erro), aparece a mensagem do erro para o usuário.
pub type Erro {
  Erro(cod_erro: CodErro, linha_erro: LinhaErro)
}

// Gera uma lista com todos os jogos da entrada convertidos para o tipo de dados Jogo. Caso o valor
// de algum jogo da entrada esteja errado, retorna-se um erro.
pub fn tabela_jogos(jogos: List(String)) -> Result(List(Jogo), Erro) {
  jogos
  |> list.map(converte_jogo(_))
  |> result.all()
}

pub fn tabela_jogos_examples() {
  check.eq(
    tabela_jogos([
      "Sao-Paulo 1 Atletico-MG 2", "Flamengo 2 Palmeiras 1",
      "Palmeiras 0 Sao-Paulo 0",
    ]),
    Ok([
      Jogo("Sao-Paulo", 1, "Atletico-MG", 2),
      Jogo("Flamengo", 2, "Palmeiras", 1),
      Jogo("Palmeiras", 0, "Sao-Paulo", 0),
    ]),
  )
  check.eq(
    tabela_jogos([
      "Sao-Paulo 1 Atletico-MG", "Flamengo 2 Palmeiras 1",
      "Palmeiras 0 Sao-Paulo 0",
    ]),
    Error(Erro(Erro01, "Sao-Paulo 1 Atletico-MG")),
  )
  check.eq(
    tabela_jogos([
      "Sao-Paulo 1 Atletico-MG 2", "Flamengo -2 Palmeiras -1",
      "Palmeiras 0 Sao-Paulo 0",
    ]),
    Error(Erro(Erro08, "Flamengo -2 Palmeiras -1")),
  )
}

pub fn converte_jogo(jogo_str: String) -> Result(Jogo, Erro) {
  case string.split(jogo_str, " ") {
    // campos faltando
    [] | [_] | [_, _] | [_, _, _] -> Error(Erro(Erro01, jogo_str))
    [primeiro, segundo, terceiro, quarto] ->
      case int.parse(segundo), int.parse(quarto) {
        // ambos os gols não numéricos
        Error(_), Error(_) -> Error(Erro(Erro05, jogo_str))
        // gol do anfitrião não numérico
        Error(_), _ -> Error(Erro(Erro03, jogo_str))
        // gol do visitante não numérico
        _, Error(_) -> Error(Erro(Erro04, jogo_str))
        Ok(segundo_int), Ok(quarto_int) ->
          case segundo_int, quarto_int {
            // ambos os gols negativos
            _, _ if segundo_int < 0 && quarto_int < 0 ->
              Error(Erro(Erro08, jogo_str))
            // gol do anfitrião negativo
            _, _ if segundo_int < 0 -> Error(Erro(Erro06, jogo_str))
            // gol do visitante não numérico
            _, _ if quarto_int < 0 -> Error(Erro(Erro07, jogo_str))
            // perfeito
            _, _ -> Ok(Jogo(primeiro, segundo_int, terceiro, quarto_int))
          }
      }
    // Campos a mais
    _ -> Error(Erro(Erro02, jogo_str))
  }
}

pub fn converte_jogo_examples() {
  check.eq(
    converte_jogo("Sao-Paulo 1 Atletico-MG 2"),
    Ok(Jogo("Sao-Paulo", 1, "Atletico-MG", 2)),
  )
  check.eq(
    converte_jogo("Sao-Paulo 1 Atletico-MG"),
    Error(Erro(Erro01, "Sao-Paulo 1 Atletico-MG")),
  )
  check.eq(
    converte_jogo("Sao-Paulo 1 Atle tico MG"),
    Error(Erro(Erro02, "Sao-Paulo 1 Atle tico MG")),
  )
  check.eq(
    converte_jogo("Sao-Paulo a Atletico-MG 2"),
    Error(Erro(Erro03, "Sao-Paulo a Atletico-MG 2")),
  )
  check.eq(
    converte_jogo("Sao-Paulo 1 Atletico-MG a"),
    Error(Erro(Erro04, "Sao-Paulo 1 Atletico-MG a")),
  )
  check.eq(
    converte_jogo("Sao-Paulo a Atletico-MG a"),
    Error(Erro(Erro05, "Sao-Paulo a Atletico-MG a")),
  )
  check.eq(
    converte_jogo("Sao-Paulo -2 Atletico-MG 2"),
    Error(Erro(Erro06, "Sao-Paulo -2 Atletico-MG 2")),
  )
  check.eq(
    converte_jogo("Sao-Paulo 2 Atletico-MG -2"),
    Error(Erro(Erro07, "Sao-Paulo 2 Atletico-MG -2")),
  )
  check.eq(
    converte_jogo("Sao-Paulo -1 Atletico-MG -2"),
    Error(Erro(Erro08, "Sao-Paulo -1 Atletico-MG -2")),
  )
}
