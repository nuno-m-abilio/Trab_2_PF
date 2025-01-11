import gleam/int
import gleam/list
import gleam/order
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

// Projeto de funções principais e auxiliares para resolução do problema:

// Gera a tabela de classificação do Brasileirão. Tomando como base os resultados dos jogos, coloca
// os times (primeira coluna) em ordem decerescente de "Número de Pontos" (segunda coluna) e, em
// caso de empates, usando os critérios "Número de Vitórias" (terceira coluna), "Saldo de Gols"
// (quarta coluna) e "Ordem Alfabética". Caso o valor de algum jogo da entrada esteja errado,
// retorna-se um erro.
pub fn classificacao_brasileirao(
  jogos: List(String),
) -> Result(List(String), Erro) {
  case tabela_jogos(jogos) {
    Ok(x) ->
      x
      |> tabela_class()
      |> str_tabela_class()
      |> Ok()
    Error(x) -> Error(x)
  }
}

pub fn classificacao_brasileirao_examples() {
  check.eq(
    classificacao_brasileirao([
      "Sao-Paulo 1 Atletico-MG 2", "Flamengo 2 Palmeiras 1",
      "Palmeiras 0 Sao-Paulo 0", "Atletico-MG 1 Flamengo 2",
    ]),
    Ok([
      "Flamengo     6  2  2   ", "Atletico-MG  3  1  0   ",
      "Palmeiras    1  0  -1  ", "Sao-Paulo    1  0  -1  ",
    ]),
  )
  check.eq(
    classificacao_brasileirao([
      "A 1 B 1", "C 2 D 1", "A 1 C 3", "B 0 D 0", "A 2 D 1", "B 1 C 4",
    ]),
    Ok(["C  9  3  6   ", "A  4  1  -1  ", "B  2  0  -3  ", "D  1  0  -2  "]),
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
      "     flamengo  20  6   9", "    palmeiras  19  6  11",
      "   fluminense  13  3   2", "  corinthians   9  3  -3",
      "       santos   7  1  -3", "        vasco   7  1  -6",
      "    sao-paulo   6  1  -2", "     botafogo   4  0  -8",
    ]),
  )
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

// Produz uma tabela de classificação ordenada a partir de uma lista de jogos verificada como sem erros.
pub fn tabela_class(jogos: List(Jogo)) -> List(Linha) {
  jogos
  |> tabela_efeitos()
  |> list.fold_right([], add_efeito)
  |> ordena()
}

pub fn tabela_class_examples() {
  check.eq(
    tabela_class([
      Jogo("Sao-Paulo", 1, "Atletico-MG", 2),
      Jogo("Flamengo", 2, "Palmeiras", 1),
      Jogo("Palmeiras", 0, "Sao-Paulo", 0),
      Jogo("Atletico-MG", 1, "Flamengo", 2),
    ]),
    [
      Linha("Flamengo", 6, 2, 2),
      Linha("Atletico-MG", 3, 1, 0),
      Linha("Palmeiras", 1, 0, -1),
      Linha("Sao-Paulo", 1, 0, -1),
    ],
  )
}

// Retorna todos os efeitos causados pelos jogos de uma lista de jogos.
pub fn tabela_efeitos(tabela_jogos: List(Jogo)) -> List(Linha) {
  tabela_jogos
  |> list.flat_map(efeitos_jogo)
}

pub fn tabela_efeitos_examples() {
  check.eq(
    tabela_efeitos([
      Jogo("Sao-Paulo", 1, "Atletico-MG", 2),
      Jogo("Flamengo", 2, "Palmeiras", 1),
      Jogo("Palmeiras", 0, "Sao-Paulo", 0),
    ]),
    [
      Linha("Sao-Paulo", 0, 0, -1),
      Linha("Atletico-MG", 3, 1, 1),
      Linha("Flamengo", 3, 1, 1),
      Linha("Palmeiras", 0, 0, -1),
      Linha("Palmeiras", 1, 0, 0),
      Linha("Sao-Paulo", 1, 0, 0),
    ],
  )
}

// Retorna uma lista com os efeitos que o resultado de Jogo afeta em cada time que participou.
// A lista contém duas Linhas com os nomes dos times, os pontos ganhados, se gerou 1 ou 0 vitórias
// e o saldo de gols.
pub fn efeitos_jogo(jogo: Jogo) -> List(Linha) {
  [
    efeito_unilateral(jogo.anf, jogo.gols_anf, jogo.gols_vis),
    efeito_unilateral(jogo.vis, jogo.gols_vis, jogo.gols_anf),
  ]
}

pub fn efeitos_jogo_examples() {
  check.eq(efeitos_jogo(Jogo("Sao-Paulo", 1, "Atletico-MG", 2)), [
    Linha("Sao-Paulo", 0, 0, -1),
    Linha("Atletico-MG", 3, 1, 1),
  ])
}

// Mostra o efeito que um placar teve pare para um time indicado.
pub fn efeito_unilateral(time: String, gols_time: Int, gols_adv: Int) -> Linha {
  Linha(
    time,
    num_pontos(gols_time > gols_adv, gols_time < gols_adv),
    num_vitorias(gols_time > gols_adv),
    gols_time - gols_adv,
  )
}

// Não fiz testes para num_pontos, pois a função é bem simples

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

// Não fiz testes para num_pontos, pois a função é bem simples

// Adiciona um efeito de um jogo na tabela de classificação (não considera ordenação)
pub fn add_efeito(tabela: List(Linha), efeito: Linha) -> List(Linha) {
  let a = list.find(tabela, fn(x: Linha) { efeito.time == x.time })
  case a {
    Ok(_) -> list.map(tabela, try_add_efeito(efeito, _))
    _ -> [efeito, ..tabela]
  }
}

pub fn add_efeito_examples() {
  check.eq(add_efeito([], Linha("Sao-Paulo", 0, 0, -1)), [
    Linha("Sao-Paulo", 0, 0, -1),
  ])
  check.eq(
    add_efeito([Linha("Sao-Paulo", 0, 0, -1)], Linha("Sao-Paulo", 3, 1, 2)),
    [Linha("Sao-Paulo", 3, 1, 1)],
  )
  check.eq(
    add_efeito([Linha("Sao-Paulo", 3, 1, 1)], Linha("Flamengo", 3, 1, 5)),
    [Linha("Flamengo", 3, 1, 5), Linha("Sao-Paulo", 3, 1, 1)],
  )
  check.eq(
    add_efeito(
      [Linha("Sao-Paulo", 3, 1, 1), Linha("Flamengo", 3, 1, 5)],
      Linha("Flamengo", 1, 0, 0),
    ),
    [Linha("Sao-Paulo", 3, 1, 1), Linha("Flamengo", 4, 1, 5)],
  )
}

// Combina um efeito com uma linha, caso ambos correspondam ao mesmo time. Caso contrário, retorna
// a linha sem interfeência do efeito.
pub fn try_add_efeito(efeito: Linha, linha: Linha) -> Linha {
  case efeito.time == linha.time {
    True ->
      Linha(
        linha.time,
        efeito.pts + linha.pts,
        efeito.vit + linha.vit,
        efeito.sg + linha.sg,
      )
    False -> linha
  }
}

// Ordena a lista de linhas em ordem decerescente de "Número de Pontos". Em caso de empates, usa os
// critérios "Número de Vitórias" , "Saldo de Gols" e "Ordem Alfabética", nessa ordem de
// prioridade. O método usado é o Insertion sort Sort.
pub fn ordena(lst: List(Linha)) -> List(Linha) {
  lst
  |> list.fold_right([], insere_ordenado)
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

pub fn insere_ordenado(tabela: List(Linha), linha: Linha) -> List(Linha) {
  let try_fold =
    list.fold_right(tabela, #([], False), fn(tupla, i) {
      let lista = tupla.0
      let achou = tupla.1
      case eh_antes(linha, i) {
        True -> #([i, ..lista], False)
        False ->
          case achou {
            False -> #([i, linha, ..lista], True)
            True -> #([i, ..lista], True)
          }
      }
    })
  case try_fold.1 {
    True -> try_fold.0
    False -> [linha, ..tabela]
  }
}

pub fn insere_ordenado_examples() {
  check.eq(insere_ordenado([], Linha("Vasco", 3, 0, 0)), [
    Linha("Vasco", 3, 0, 0),
  ])
  check.eq(
    insere_ordenado([Linha("Flamengo", 6, 2, 2)], Linha("Vasco", 3, 0, 0)),
    [Linha("Flamengo", 6, 2, 2), Linha("Vasco", 3, 0, 0)],
  )
  check.eq(
    insere_ordenado(
      [
        Linha("Flamengo", 6, 2, 2),
        Linha("Atletico-MG", 3, 1, 0),
        Linha("Palmeiras", 1, 0, -1),
        Linha("Sao-Paulo", 1, 0, -1),
      ],
      Linha("Vasco", 3, 0, 0),
    ),
    [
      Linha("Flamengo", 6, 2, 2),
      Linha("Atletico-MG", 3, 1, 0),
      Linha("Vasco", 3, 0, 0),
      Linha("Palmeiras", 1, 0, -1),
      Linha("Sao-Paulo", 1, 0, -1),
    ],
  )
  check.eq(
    insere_ordenado(
      [
        Linha("Flamengo", 6, 2, 2),
        Linha("Atletico-MG", 3, 1, 0),
        Linha("Palmeiras", 1, 0, -1),
        Linha("Sao-Paulo", 1, 0, -1),
      ],
      Linha("Vasco", 9, 3, 5),
    ),
    [
      Linha("Vasco", 9, 3, 5),
      Linha("Flamengo", 6, 2, 2),
      Linha("Atletico-MG", 3, 1, 0),
      Linha("Palmeiras", 1, 0, -1),
      Linha("Sao-Paulo", 1, 0, -1),
    ],
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

pub fn maiores_tamanhos(lista: List(Linha)) -> List(Int) {
  lista
  |> list.map(tamanhos)
  |> list.fold([0, 0, 0, 0], mapeia2_max)
}

pub fn maiores_tamanhos_examples() {
  check.eq(
    maiores_tamanhos([
      Linha("Flamengo", 10, 2, 2),
      Linha("Atletico-MG", 3, 1, 0),
      Linha("Palmeiras", 1, 0, -1),
      Linha("Sao-Paulo", 1, 0, -1),
    ]),
    [11, 2, 1, 2],
  )
}

// Combina duas listas em uma usando a função int.max. Dessa forma, comparando qual o maior entre o
// nº elemento da 1ª lista com o nº elemento da 2ª lista, gera-se uma nova lista.
pub fn mapeia2_max(a: List(Int), b: List(Int)) {
  list.map2(a, b, int.max)
}

// // Combina duas listas em uma usando a função stirng.pad_end.
// pub fn mapeia2_pad_end(a: List(String), b: List(Int)) -> List(String) {
//   list.map2(a, b, pad_end)
// }

pub fn pad_right(a: String, b: Int) -> String {
  string.pad_right(a, b + 2, " ")
}

pub fn pad_left(a: String, b: Int) -> String {
  string.pad_left(a, b + 2, " ")
}

// Gera os tamanhos das strings respectivas de cada elemento de uma linha.
pub fn tamanhos(linha: Linha) -> List(Int) {
  linha
  |> linha_lista_str()
  |> list.map(string.length)
}

// Transforma uma lista de Linhas em uma lista de Strings
pub fn str_tabela_class(lista: List(Linha)) -> List(String) {
  let tam_max = maiores_tamanhos(lista)
  list.map(lista, str_linha(_, tam_max))
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
      "Flamengo     6  2  2   ", "Atletico-MG  3  1  0   ",
      "Palmeiras    1  0  -1  ", "Sao-Paulo    1  0  -1  ",
    ],
  )
}

// Transforma uma Linha em uma String
pub fn str_linha(linha: Linha, tam_max: List(Int)) -> String {
  linha
  |> linha_lista_str()
  |> list.map2(tam_max, pad_right)
  |> list.fold("", string.append)
}

// // Transforma uma Linha em uma String
// pub fn str_linha(linha: Linha, tam_max: List(Int)) -> String {
//   case linha_lista_str(linha), tam_max {
//     [p, ..r], [j, ..k] ->
//       list.fold(
//         [pad_right(p, j), ..list.map2(k, pad_left(r))],
//         "",
//         string.append,
//       )
//     _, _ -> panic
//   }
// }

pub fn str_linha_examples() {
  check.eq(
    str_linha(Linha("Flamengo", 6, 2, 2), [10, 1, 1, 2]),
    "Flamengo    6  2  2   ",
  )
}

// Transforma cada elemento de i=uma linha individualmente em Strings
pub fn linha_lista_str(linha: Linha) -> List(String) {
  [
    linha.time,
    int.to_string(linha.pts),
    int.to_string(linha.vit),
    int.to_string(linha.sg),
  ]
}