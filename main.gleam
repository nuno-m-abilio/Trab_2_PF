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
