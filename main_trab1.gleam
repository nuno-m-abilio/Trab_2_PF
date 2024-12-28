import gleam/int
import gleam/list
import gleam/order
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
// "Número de Vitórias", "Saldo de Gols" e "Ordem Alfabética".

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

// Projeto de funções principais e auxiliares para resolução do problema:

// Gera a tabela de classificação do Brasileirão. Tomando como base os resultados dos jogos, coloca
// os times (primeira coluna) em ordem decerescente de "Número de Pontos" (segunda coluna) e, em
// caso de empates, usando os critérios "Número de Vitórias" (terceira coluna), "Saldo de Gols"
// (quarta coluna) e "Ordem Alfabética". Caso o valor de algum jogo da entrada esteja errado,
// retorna-se um erro.
pub fn classificacao_brasileirao(
  jogos: List(String),
) -> Result(List(String), Erro) {
  case tabela_class(tabela_jogos(jogos)) {
    Ok(tabela_class) -> Ok(str_tabela_class(ordena(tabela_class)))
    Error(Erro(cod_erro, linha_erro)) -> Error(Erro(cod_erro, linha_erro))
  }
}

pub fn classificacao_brasileirao_examples() {
  check.eq(
    classificacao_brasileirao([
      "Sao-Paulo 1 Atletico-MG 2", "Flamengo 2 Palmeiras 1",
      "Palmeiras 0 Sao-Paulo 0", "Atletico-MG 1 Flamengo 2",
    ]),
    Ok([
      "Flamengo 6 2 2", "Atletico-MG 3 1 0", "Palmeiras 1 0 -1",
      "Sao-Paulo 1 0 -1",
    ]),
  )
  check.eq(
    classificacao_brasileirao([
      "A 1 B 1", "C 2 D 1", "A 1 C 3", "B 0 D 0", "A 2 D 1", "B 1 C 4",
    ]),
    Ok(["C 9 3 6", "A 4 1 -1", "B 2 0 -3", "D 1 0 -2"]),
  )
  check.eq(
    classificacao_brasileirao([
      "Sao-Paulo -1 Atletico-MG 2", "Flamengo 2 Palmeiras 1",
      "Palmeiras 0 Sao-Paulo 0", "Atletico-MG 1 Flamengo 2",
    ]),
    Error(Erro(Erro06, "Sao-Paulo -1 Atletico-MG 2")),
  )
  check.eq(
    classificacao_brasileirao([
      "Sao-Paulo a Atletico-MG 2", "Flamengo 2 Palmeiras 1",
      "Palmeiras 0 Sao-Paulo 0", "Atletico-MG 1 Flamengo 2",
    ]),
    Error(Erro(Erro03, "Sao-Paulo a Atletico-MG 2")),
  )
  check.eq(
    classificacao_brasileirao([
      "Sao Paulo 1 Atletico-MG 2", "Flamengo 2 Palmeiras 1",
      "Palmeiras 0 Sao-Paulo 0", "Atletico-MG 1 Flamengo 2",
    ]),
    Error(Erro(Erro02, "Sao Paulo 1 Atletico-MG 2")),
  )
  check.eq(
    classificacao_brasileirao([
      "Flamengo 2 Palmeiras 1", "Sao-Paulo Atletico-MG 2",
      "Palmeiras 0 Sao-Paulo 0", "Atletico-MG 1 Flamengo 2",
    ]),
    Error(Erro(Erro01, "Sao-Paulo Atletico-MG 2")),
  )
  check.eq(
    classificacao_brasileirao([
      "flamengo 2 vasco 0", "fluminense 1 botafogo 1", "palmeiras 3 santos 2",
      "corinthians 0 sao-paulo 1", "santos 1 flamengo 1",
      "botafogo 0 palmeiras 2", "sao-paulo 2 vasco 2",
      "fluminense 3 corinthians 1", "vasco 1 palmeiras 1",
      "flamengo 3 fluminense 2", "corinthians 2 santos 0",
      "botafogo 1 sao-paulo 1", "flamengo 2 palmeiras 1",
      "santos 3 fluminense 3", "botafogo 0 corinthians 2",
      "sao-paulo 3 flamengo 3", "fluminense 2 vasco 0",
      "palmeiras 4 corinthians 1", "botafogo 2 santos 2", "vasco 1 flamengo 4",
      "sao-paulo 0 fluminense 1", "palmeiras 3 botafogo 0",
      "santos 1 sao-paulo 0", "corinthians 1 vasco 2",
      "fluminense 1 palmeiras 3", "flamengo 2 botafogo 1", "santos 0 vasco 0",
      "corinthians 3 sao-paulo 2", "fluminense 0 botafogo 0",
      "palmeiras 2 santos 1", "vasco 3 fluminense 3", "flamengo 1 corinthians 0",
    ]),
    Ok([
      "flamengo 20 6 9", "palmeiras 19 6 11", "fluminense 13 3 2",
      "corinthians 9 3 -3", "santos 7 1 -3", "vasco 7 1 -6", "sao-paulo 6 1 -2",
      "botafogo 4 0 -8",
    ]),
  )
}

// Gera uma lista com todos os jogos da entrada convertidos para o tipo de dados Jogo. Caso o valor
// de algum jogo da entrada esteja errado, retorna-se um erro.
pub fn tabela_jogos(jogos: List(String)) -> Result(List(Jogo), Erro) {
  case jogos {
    [] -> Ok([])
    [primeiro, ..resto] ->
      case converte_jogo(primeiro), tabela_jogos(resto) {
        Ok(jogo_convertido), Ok(tabela_resto_ok) ->
          Ok([jogo_convertido, ..tabela_resto_ok])
        Error(erro), _ -> Error(erro)
        _, Error(erro) -> Error(erro)
      }
  }
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

// Converte um resultado de jogo na forma de String para a formatação no tipo Jogo, caso a String
// tenha a representação correta. Caso contrário, retorna-se o erro correspondente.
pub fn converte_jogo(jogo_str: String) -> Result(Jogo, Erro) {
  case separa_jogo(jogo_str) {
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

// Produz uma lista com os elementos da String de entrada separados pelos caracteres de espaço. É
// como se os caracteres de espaço na String se tornassem vírgulas na lista.
pub fn separa_jogo(jogo_str: String) -> List(String) {
  case string.first(jogo_str) {
    Error(_) -> []
    Ok(inicial_str) ->
      case inicial_str, separa_jogo(string.drop_left(jogo_str, 1)) {
        " ", [] -> ["", ""]
        " ", resto -> ["", ..resto]
        letra, [] -> [letra]
        letra, [primeiro, ..resto] -> [letra <> primeiro, ..resto]
      }
  }
}

pub fn separa_jogo_examples() {
  check.eq(separa_jogo("Sao-Paulo 1 Atletico-MG 2"), [
    "Sao-Paulo", "1", "Atletico-MG", "2",
  ])
  check.eq(separa_jogo(""), [])
  check.eq(separa_jogo(" Sao-Paulo 1 Atletico-MG 2"), [
    "", "Sao-Paulo", "1", "Atletico-MG", "2",
  ])
  check.eq(separa_jogo("Sao Paulo"), ["Sao", "Paulo"])
  check.eq(separa_jogo("   "), ["", "", "", ""])
}

// Produz uma tabela de classificação. É precursora da função principal classificacao_brasileirao,
// mas aqui os argumentos e resposta ainda são Results com listas de jogos e linhas.
pub fn tabela_class(
  jogos: Result(List(Jogo), Erro),
) -> Result(List(Linha), Erro) {
  case jogos {
    Ok(jogos_ok) ->
      case jogos_ok {
        [] -> Ok([])
        [primeiro, ..resto] ->
          case tabela_class(Ok(resto)) {
            Ok(tabela) -> Ok(add_efeitos(efeitos_jogo(primeiro), tabela))
            Error(erro) -> Error(erro)
          }
      }
    Error(erro) -> Error(erro)
  }
}

pub fn tabela_class_examples() {
  check.eq(
    tabela_class(
      tabela_jogos([
        "Sao-Paulo 1 Atletico-MG 2", "Flamengo 2 Palmeiras 1",
        "Palmeiras 0 Sao-Paulo 0", "Atletico-MG 1 Flamengo 2",
      ]),
    ),
    Ok([
      Linha("Atletico-MG", 3, 1, 0),
      Linha("Flamengo", 6, 2, 2),
      Linha("Palmeiras", 1, 0, -1),
      Linha("Sao-Paulo", 1, 0, -1),
    ]),
  )
}

// Retorna uma lista com os efeitos que o resultado de Jogo afeta em cada time que participou.
// A lista contém duas Linhas com os nomes dos times, os pontos ganhados, se gerou 1 ou 0 vitórias
// e o saldo de gols.
pub fn efeitos_jogo(jogo: Jogo) -> List(Linha) {
  [
    Linha(
      jogo.anf,
      num_pontos(jogo.gols_anf > jogo.gols_vis, jogo.gols_anf < jogo.gols_vis),
      num_vitorias(jogo.gols_anf > jogo.gols_vis),
      jogo.gols_anf - jogo.gols_vis,
    ),
    Linha(
      jogo.vis,
      num_pontos(jogo.gols_vis > jogo.gols_anf, jogo.gols_vis < jogo.gols_anf),
      num_vitorias(jogo.gols_vis > jogo.gols_anf),
      jogo.gols_vis - jogo.gols_anf,
    ),
  ]
}

pub fn efeitos_jogo_examples() {
  check.eq(efeitos_jogo(Jogo("Sao-Paulo", 1, "Atletico-MG", 2)), [
    Linha("Sao-Paulo", 0, 0, -1),
    Linha("Atletico-MG", 3, 1, 1),
  ])
}

// Indica quantos pontos um time ganhou no jogo. Se ele teve vitória, 3 pontos, se ele teve derrota,
// 0 pontos, se nem vitória nem derrota, então foi um empate, ou seja, 1 ponto.
pub fn num_pontos(vitoria: Bool, derrota: Bool) -> Int {
  case vitoria {
    True -> 3
    False ->
      case derrota {
        True -> 0
        // Empate
        False -> 1
      }
  }
}

// Não fiz testes para num_pontos, pois a função é bem simples

// Indica se o time deve 1 ou 0 vitórias em um jogo. Parece besta, mas é útil.
pub fn num_vitorias(vitoria: Bool) -> Int {
  case vitoria {
    True -> 1
    False -> 0
  }
}

// Não fiz testes para num_vitorias, pois a função é bem simples

// Adiciona os efeitos de um jogo presentes em uma lista na tabela de classificação (não considera
// ordenação)
pub fn add_efeitos(efeitos: List(Linha), tabela: List(Linha)) -> List(Linha) {
  case efeitos {
    [] -> tabela
    [primeiro, ..resto] -> add_efeitos(resto, add_1_efeito(primeiro, tabela))
  }
}

pub fn add_efeitos_examples() {
  check.eq(
    add_efeitos([Linha("Sao-Paulo", 0, 0, -5), Linha("Flamengo", 3, 1, 5)], [
      Linha("Sao-Paulo", 3, 1, 1),
      Linha("Flamengo", 3, 1, 5),
    ]),
    [Linha("Sao-Paulo", 3, 1, -4), Linha("Flamengo", 6, 2, 10)],
  )
}

// Adiciona um efeito de um jogo na tabela de classificação (não considera ordenação)
pub fn add_1_efeito(efeito: Linha, tabela: List(Linha)) -> List(Linha) {
  case tabela {
    [] -> [efeito]
    [primeiro, ..resto] ->
      case efeito.time == primeiro.time {
        True -> [
          Linha(
            primeiro.time,
            efeito.pts + primeiro.pts,
            efeito.vit + primeiro.vit,
            efeito.sg + primeiro.sg,
          ),
          ..resto
        ]
        False -> [primeiro, ..add_1_efeito(efeito, resto)]
      }
  }
}

pub fn add_1_efeito_examples() {
  check.eq(add_1_efeito(Linha("Sao-Paulo", 0, 0, -1), []), [
    Linha("Sao-Paulo", 0, 0, -1),
  ])
  check.eq(
    add_1_efeito(Linha("Sao-Paulo", 3, 1, 2), [Linha("Sao-Paulo", 0, 0, -1)]),
    [Linha("Sao-Paulo", 3, 1, 1)],
  )
  check.eq(
    add_1_efeito(Linha("Flamengo", 3, 1, 5), [Linha("Sao-Paulo", 3, 1, 1)]),
    [Linha("Sao-Paulo", 3, 1, 1), Linha("Flamengo", 3, 1, 5)],
  )
  check.eq(
    add_1_efeito(Linha("Flamengo", 1, 0, 0), [
      Linha("Sao-Paulo", 3, 1, 1),
      Linha("Flamengo", 3, 1, 5),
    ]),
    [Linha("Sao-Paulo", 3, 1, 1), Linha("Flamengo", 4, 1, 5)],
  )
}

// Ordena a lista de linhas em ordem decerescente de "Número de Pontos". Em caso de empates, usa os
// critérios "Número de Vitórias" , "Saldo de Gols" e "Ordem Alfabética", nessa ordem de
// prioridade. O método usado é o Quick Sort.
pub fn ordena(lst: List(Linha)) -> List(Linha) {
  case lst {
    [] | [_] -> lst
    [primeiro, ..resto] -> {
      let lsts_piv = lst_pivotada(primeiro, resto)
      list.concat([ordena(lsts_piv.0), [primeiro], ordena(lsts_piv.1)])
    }
  }
}

pub fn ordena_examples() {
  check.eq(
    ordena([
      Linha("Palmeiras", 1, 0, -1),
      Linha("Atletico-MG", 3, 1, 0),
      Linha("Sao-Paulo", 1, 0, -1),
      Linha("Flamengo", 6, 2, 2),
    ]),
    [
      Linha("Flamengo", 6, 2, 2),
      Linha("Atletico-MG", 3, 1, 0),
      Linha("Palmeiras", 1, 0, -1),
      Linha("Sao-Paulo", 1, 0, -1),
    ],
  )
}

// Gera duas listas. Uma com todos os elementos menores que o pivô da lista (elemento 0 da tupla) e
// outra com todos os elementos maiores (elemento 1 da tupla).
pub fn lst_pivotada(
  pivo: Linha,
  lst: List(Linha),
) -> #(List(Linha), List(Linha)) {
  case lst {
    [] -> #([], [])
    [primeiro, ..resto] -> {
      let lsts_piv = lst_pivotada(pivo, resto)
      case eh_antes(primeiro, pivo) {
        True -> #([primeiro, ..lsts_piv.0], lsts_piv.1)
        False -> #(lsts_piv.0, [primeiro, ..lsts_piv.1])
      }
    }
  }
}

pub fn lst_pivotada_examples() {
  check.eq(
    lst_pivotada(Linha("Palmeiras", 1, 0, -1), [
      Linha("Atletico-MG", 3, 1, 0),
      Linha("Sao-Paulo", 1, 0, -1),
      Linha("Flamengo", 6, 2, 2),
    ]),
    #([Linha("Atletico-MG", 3, 1, 0), Linha("Flamengo", 6, 2, 2)], [
      Linha("Sao-Paulo", 1, 0, -1),
    ]),
  )
}

// Confere se uma lenha vem antes do pivô conforme os critérios de ordenação. Ressalta-se que os
// critérios usados são maior "Número de Pontos", maior "Número de Vitórias", maior "Saldo de
// Gols" e "Ordem Alfabética", nessa ordem de prioridade.
pub fn eh_antes(primeiro: Linha, pivo: Linha) -> Bool {
  { primeiro.pts > pivo.pts }
  || { primeiro.pts == pivo.pts && primeiro.vit > pivo.vit }
  || {
    primeiro.pts == pivo.pts
    && primeiro.vit == pivo.vit
    && primeiro.sg > pivo.sg
  }
  || {
    primeiro.pts == pivo.pts
    && primeiro.vit == pivo.vit
    && primeiro.sg == pivo.sg
    && string.compare(primeiro.time, pivo.time) == order.Lt
  }
}

pub fn eh_antes_examples() {
  check.eq(
    eh_antes(Linha("Palmeiras", 1, 0, -1), Linha("Flamengo", 6, 2, 2)),
    False,
  )
  check.eq(
    eh_antes(Linha("Palmeiras", 3, 0, -1), Linha("Flamengo", 3, 1, 2)),
    False,
  )
  check.eq(
    eh_antes(Linha("Palmeiras", 6, 2, -1), Linha("Flamengo", 6, 2, 2)),
    False,
  )
  check.eq(
    eh_antes(Linha("Palmeiras", 1, 0, -1), Linha("Sao-Paulo", 1, 0, -1)),
    True,
  )
}

// Transforma uma lista de Linhas em uma lista de Strings
pub fn str_tabela_class(lista: List(Linha)) -> List(String) {
  case lista {
    [] -> []
    [primeira, ..resto] -> [str_linha(primeira), ..str_tabela_class(resto)]
  }
}

pub fn str_tabela_class_examples() {
  check.eq(
    str_tabela_class([
      Linha("Flamengo", 6, 2, 2),
      Linha("Atletico-MG", 3, 1, 0),
      Linha("Palmeiras", 1, 0, -1),
      Linha("Sao-Paulo", 1, 0, -1),
    ]),
    [
      "Flamengo 6 2 2", "Atletico-MG 3 1 0", "Palmeiras 1 0 -1",
      "Sao-Paulo 1 0 -1",
    ],
  )
}

// Transforma uma Linha em uma String
pub fn str_linha(linha: Linha) -> String {
  linha.time
  <> " "
  <> int.to_string(linha.pts)
  <> " "
  <> int.to_string(linha.vit)
  <> " "
  <> int.to_string(linha.sg)
}

pub fn str_linha_examples() {
  check.eq(str_linha(Linha("Flamengo", 6, 2, 2)), "Flamengo 6 2 2")
  check.eq(str_linha(Linha("Atletico-MG", 3, 1, 0)), "Atletico-MG 3 1 0")
}

// EXTRA: Função que retorna a mensagem de erro para o usuário

// Retorna a mensagem de erro que o usuário receberia ao obter um erro chamando a função principal.
// Essa mensagem informa o código do erro, o motivo do erro e a linha que o causou.
pub fn mensagem_erro(erro: Erro) -> String {
  case erro.cod_erro {
    Erro01 ->
      "Erro #01: A formatação do jogo "
      <> erro.linha_erro
      <> " está incorreta. Há menos que 4 campos de informações"
    Erro02 ->
      "Erro #02: A formatação do jogo "
      <> erro.linha_erro
      <> " está incorreta. Há mais que 4 campos de informações"
    Erro03 ->
      "Erro #03: Valores do jogo "
      <> erro.linha_erro
      <> " estão incoerentes. O segundo campo, que deveria representar um valor numérico, aqui não"
      <> " o faz."
    Erro04 ->
      "Erro #04: Valores do jogo "
      <> erro.linha_erro
      <> " estão incoerentes. O quarto campo, que deveria representar um valor numérico, aqui não "
      <> "o faz."
    Erro05 ->
      "Erro #05: Os valores do jogo "
      <> erro.linha_erro
      <> " estão incoerentes. Tanto o segundo quanto o quarto campo, que deveriam representar valo"
      <> "res numéricos, aqui não o fazem."
    Erro06 ->
      "Erro #06: Valores do jogo "
      <> erro.linha_erro
      <> " estão incoerentes. O segundo campo, que deveria representar um inteiro positivo, aqui n"
      <> "ão o faz."
    Erro07 ->
      "Erro #07: Valores do jogo "
      <> erro.linha_erro
      <> " estão incoerentes. O quarto campo, que deveria representar um inteiro positivo, aqui nã"
      <> "o o faz."
    Erro08 ->
      "Erro #08: Os valores do jogo "
      <> erro.linha_erro
      <> " estão incoerentes. Tanto o segundo quanto o quarto campo, que deveriam representar intei"
      <> "ros positivos, aqui não o fazem."
  }
}

pub fn mensagem_erro_examples() {
  check.eq(
    mensagem_erro(Erro(Erro01, "Sao-Paulo 1 Atletico-MG")),
    "Erro #01: A formatação do jogo Sao-Paulo 1 Atletico-MG está incorreta. Há menos que 4 campos "
      <> "de informações",
  )
  check.eq(
    mensagem_erro(Erro(Erro02, "Sao-Paulo 1 Atle tico MG")),
    "Erro #02: A formatação do jogo Sao-Paulo 1 Atle tico MG está incorreta. Há mais que 4 campos "
      <> "de informações",
  )
  check.eq(
    mensagem_erro(Erro(Erro03, "Sao-Paulo a Atletico-MG 2")),
    "Erro #03: Valores do jogo Sao-Paulo a Atletico-MG 2 estão incoerentes. O segundo campo, que d"
      <> "everia representar um valor numérico, aqui não o faz.",
  )
  check.eq(
    mensagem_erro(Erro(Erro04, "Sao-Paulo 1 Atletico-MG a")),
    "Erro #04: Valores do jogo Sao-Paulo 1 Atletico-MG a estão incoerentes. O quarto campo, que de"
      <> "veria representar um valor numérico, aqui não o faz.",
  )
  check.eq(
    mensagem_erro(Erro(Erro05, "Sao-Paulo a Atletico-MG a")),
    "Erro #05: Os valores do jogo Sao-Paulo a Atletico-MG a estão incoerentes. Tanto o segundo qua"
      <> "nto o quarto campo, que deveriam representar valores numéricos, aqui não o fazem.",
  )
  check.eq(
    mensagem_erro(Erro(Erro06, "Sao-Paulo -2 Atletico-MG 2")),
    "Erro #06: Valores do jogo Sao-Paulo -2 Atletico-MG 2 estão incoerentes. O segundo campo, que "
      <> "deveria representar um inteiro positivo, aqui não o faz.",
  )
  check.eq(
    mensagem_erro(Erro(Erro07, "Sao-Paulo 2 Atletico-MG -2")),
    "Erro #07: Valores do jogo Sao-Paulo 2 Atletico-MG -2 estão incoerentes. O quarto campo, que d"
      <> "everia representar um inteiro positivo, aqui não o faz.",
  )
  check.eq(
    mensagem_erro(Erro(Erro08, "Sao-Paulo -1 Atletico-MG -2")),
    "Erro #08: Os valores do jogo Sao-Paulo -1 Atletico-MG -2 estão incoerentes. Tanto o segundo q"
      <> "uanto o quarto campo, que deveriam representar inteiros positivos, aqui não o fazem.",
  )
}
