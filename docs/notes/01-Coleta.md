







```



# Obtenção dos dados

O procedimento abaixo percorre o caminho para baixar, limpar e organizar as decisões do Supremo Tribunal Federal sobre a ação de reclamação. Para realizar este procedimento, utilizou-se um conjunto de rotinas de computador. Esse conjunto de rotinas foi criado dentro do ambiente de programação estatística [R](https://www.r-project.org/). A cada uma das rotinas é dado um nome. Esses nomes são agrupados no aplicativo conhecido como `package` (pacote de funções) de uma determinada linguagem de programação. A esse  pacote também é dado um nome, que no caso se chama [stf](https://jjesusfilho.github.io/stf/). Uma vez incorporadas num aplicativo, as rotinas, doravante chamadas de funções,  podem ser facilmente reutilizadas, bastando chamá-las pelo nome e informar os argumentos para sua execução dentro de parênteses. 

A utilização do pacote `stf` confere replicabilidade e reprodutibilidade à pesquisa. As pesquisas científicas atuais, especialmente as quantitativas, caminham no sentido de garantir a reprodutibilidade, isto é, o caminho percorrido pelo pesquisador no processo de coleta, organização, exploração e análise dos dados, pode ser reproduzido por qualquer outra pesquisadora que tenha familiaridade com o programa utilizado. Reproducibilidade significa usar os mesmos dados e a mesma análise (códigos e modelos) e chegar aos mesmos resultados. Replicabilidade significa aproveitar o mesmo método (código e análise) para aplicá-los a novos dados.

O `R` é um ambiente de programação com código aberto e gratuio. Igualmente, o pacote stf é de livre acesso. Para acessá-lo, basta clicar no seguinte [link](https://github.io/jjesusfilho/stf). Ali se encontram as orientações sobre como utilizá-lo. 

O [pacote stf](https://github.io/jjesusfilho/stf) foi construído pensando em oferecer a acadêmicos de direito, de estatística e de ciência da computação, ferramentas para condução de suas análises sobre a atuação do Supremo Tribunal Federal. 

## Pacotes necessários


```r
install.packages(c("devtools","tidyverse","janitor","quanteda"))


devtools::install_github("jjesusfilho/stf")
library(stf)
library(tidyverse)
library(janitor)
```

## Baixar o acervo do STF

O acervo de decisões do STF é composto por três grupos de decisões: monocráticas, correspondentes às decisões individuais dos ministros; colegiadas, correspondentes às decisões das turmas e do pleno; presidente, correspondentes as decisões do presidente.  A função seguinte irá baixar todo o acervo de decisões do STF correspondente aos anos indicados e o tipo de decisão.


```r
download_stf_collection(decision_type = "monocraticas",years = 2011:2018,dir = "monocraticas")
download_stf_collection(decision_type = "colegiadas",years = 2011:2018,dir = "colegiadas")
download_stf_collection(decision_type = "presidente",years = 2011:2018,dir = "presidente")
```

## Ler o acervo

A função abaixo importa o acervo conforme a classe processual e os anos indicados. Esta função já faz o trabalho inicial de limpar a base de alguns elementos desnecessários e criar uma coluna chamada "incidente", que é extraída do hyperlink.


```r
monocraticas <- read_stf_collection(classes = "Rcl",years = 2011:2018,dir = "monocraticas")
colegiadas <- read_stf_collection(classes = "Rcl",years = 2011:2018,dir = "colegiadas")
presidente <- read_stf_collection(classes = "Rcl",years = 2011:2018,dir = "presidente")
```

## Junção das bases

Antes de seguir para os próximos passos, temos de juntar essas três bases e selecionar os processos únicos, de modo a reduzir o número de requisições de processos nos passos seguintes.


```r
acervo <- bind_rows(monocraticas,colegiadas, presidente)

numeros <- unique(acervo$numero)
```

Os números revelam que houve 22532 reclamações julgadas pelo Supremo Tribunal Federal entre janeiro de 2011 e dezembro de 2018.

## Remover colunas não utilizadas

Para esta análise específica, somente algumas colunas são de interesse. O procedimento abaixo seleciona tais colunas.


```r
acervo <- acervo %>% 
  select(classe,numero,data_autuacao,relator_atual,tipo_decisao,orgao_julgador,data_andamento)
```


## Baixar os processos

A maneira mais rápida de baixar os processos seria por meio da coluna incidente. No entanto, notou-se que nem sempre o `hiperlink`, do qual é extraído o número do incidente, existe. Dessa forma, optou-se utilizar o número do processo na busca. A função abaixo realiza a busca no portal do STF.

Tal busca poderá demorar bastante tempo porque são necessárias múltiplas requisições para cada um dos processos,  correspondentes aos detalhes básicos que aparecem no topo das informações processuais e às oito abas.

Esta função irá criar nove pastas dentro do diretório indicado, correspondentes às oito abas mais a pasta com os detalhes (metadados). Veja que para baixar esses arquivos, é necessário ter lido o acervo antes, pois utilizaremos as colunas classe e número para baixá-los.


```r
download_stf_dockets(classes = "Rcl",docket_number = numeros)
```

## Lendo as informações processuais.

Das nove pastas, quatro delas são de especial interesse: detalhes, andamentos, partes e informações. Para a nossa análise, as demais são dispensáveis.


```r
detalhes <- read_stf_details(path = "detalhes", plan = "multicore")

andamentos <- read_stf_docket_sheet(path = "andamentos", plan = "multicore")

informacoes <- read_stf_information(path = "informacoes", plan = "multicore")

partes <- read_stf_parties(path = "partes", plan = "multicore")
```

