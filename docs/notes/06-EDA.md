




# Análise exploratória de dados

Realizado o trabalho de coleta, limpeza e organização dos dados, a etapa seguinte é conduzir a análise exploratória de dados (EDA na sigla em inglês). A análise exploratória de dados visa dar a conhecer a estrutura subjacente dos dados e expor um conjunto de informações acerca dos dados a fim de que a pesquisadora passa tomar passos adiante ou atrás no processo de análise. Igualmente, ela fornece um sumário descritivo. Segundo [@pearson2018exploratory], a análise exploratória dos dados coletados sobre as reclamações ao STF busca responder as seguintes questões:

1. Quantos registros a base de dados sobre reclamações contêm? (Isto é, quantas decisões do STF sobre reclamações estão sendo analisadas)
2. Quantas colunas, i.e, variáveis, estão incluídas em cada um dos registros?
3. Que tipo de variáveis são essas? (i.e. numéricas, categóricas, contínuas, discretas?)
4. Esses dados foram todos observados? (i.e. há dados faltantes, há outliers?)
5. As variáveis incluídas na base são aquelas que nós realmente estávamos esperando?
6. Os valores contidos nas variáveis são consistentes?, i.e. número de categorias, categorias corretas etc, ?
7. As associações entre as variáveis são aquelas que esperávamos? 
7.1 Por exemplo, podemos esperar que o CPC 2015 elevou o número de procedência dos pedidos?
7.2 Podemos esperar diferenças entre os ministros quanto ao número de casos procedentes ou não?

É importante destacar que a análise exploratória é útil para verificar a associação entre as variáveis, particularmente entre as variáveis preditoras e a variável resposta. Inclusive iremos realizar alguns testes de associação, e.g, chi-quadrado, de força dessas associações (WOE) e mesmo capacidade preditiva das variáveis explicativas. No entanto, é fundamental tomar em conta que os testes de associação e de significância, tal como o teste do chi-quadrado e o t-test, não informam nada sobre o efeito marginal de cada uma das variáveis explicativas sobre a variável resposta. Em pesquisas experimentais, isso é perfeitamente possível porque o pesquisador possui controle preciso sobre os fatores que causam ou modificam o resultado obtido. Por sua vez, as pesquisas em ciências sociais se caracterizam por serem observacionais e a pesquisadora não possui controle apriorístico sobre o efeito de uma variável sobre a outra. Ela precisa precisa considerar outros fatores que afetam o resultado para assim isolar o efeito de cada uma das variáveis explicativas sobre o resultado[@silva2018desenho].

Na pesquisa em tela, estamos diante de dados observacionais. O esforço é dirigido em identificar todos os possíveis fatores que influenciam a resposta judicial ao pedido. Nesse sentido, os testes de associação bivariados são inadequados porque irão superdimensionar o efeito de uma variável sobre a outra. A tarefa, a qual será executada na próxima seção, será de isolar o efeito de cada uma das variáveis explicativas sobre a variável resposta: decisão judicial. Com efeito, podemos supor que o ministro A julgará diferentemente o pedido de reclamação quando se tratar de uma alegada violação a uma súmula do STF do que quando se tratar de uma violaçã a uma decisão inter partes ou que uma reclamação contra decisão da justiça do trabalho tem maior probabilidade de ter uma resposta favorável quando o ministro é fulano do que quando este é beltrano. Esse tipo de controle somente é posssível realizar por meio das técnicas de regressão, pois o objetivo destas é justamente isolar o efeito de cada uma das variáveis sobre os resultado.




## Estatísticas das variáveis



```r
rcl_dataset <- readRDS("../data/rcl_dataset.rds")
(
  descricao1 <- ExpData(rcl_dataset,1) %>% 
setNames(c("Descrições","Registros"))
)
```




```r
(
descricao2<-ExpData(rcl_dataset,2) %>% 
  select(-1) %>% 
  setNames(c("Nome da variável","Tipo de variável","% dados faltantes","No. valores únicos"))
)
```



```r
(
frequencias <- ExpCTable(rcl_dataset,Target="decisao",margin=1,clim=10,nlim=NULL,round=2,bin=NULL,per=T) %>% 
  setNames(c("Variável","Categoria","Número","decisao:improcedente","decisao:procedente","TOTAL"))
)
```


## Valor da informação e peso de evidência

Em análise de respostas binárias, duas medidas muito utilizadas nas análises para concessão de crédito, mas quase desconhecidas nas demais áreas, são o peso da evidência e o valor da informação (WOE e IV nas siglas em inglês). Essas duas medidas são importantes na fase de exploração dos dados porque elas: 

1. Levam em conta a contribuição independente de cada variável para o resultado.
2. Detetam relações lineares e não lineares com a veriável resposta
3. Classificam as variáveis em termos de força preditiva “univariada”.
4. Visualize as correlações entre as variáveis preditivas e o resultado binário.
5. Comparam perfeitamente a força de variáveis contínuas e categóricas sem criar variáveis fictícias.
6. Tratam  perfeitamente de dados faltantes (missing) sem imputação.
7. Avaliam o poder preditivo dos dados faltantes.


WOE e IV são conceitos relacionados e foram gestados na teoria da informação a fim de medir o grau de incerteza envolvido na predição de eventos, dados os diferentes graus de conhecimento sobre as variáveis envolvidas. Em poucas palavras WOE descreve a relação entre uma variável preditiva e a variável binária alvo, no caso a decisão judicial, Por sua vez IV mede a força dessa relação.

WOE describes the relationship between a predictive variable and a binary target variable.

A tabela a seguir mostra os resultados

•	Variável – nome da variável

•	Decisão - Variável resposta (decisão judicial)

•	classe – classe da variável

•	out0 – Número de procedentes

•	out1 – Número de improcedentes

•	Total – Total de respostas para cada categoria

•	pe_1 – procedentes / total de procedentes (em percentual)

•	pe_0 – improcedentes / total de improcedentes (em percentual)

•	odds – pe_1/pe_0

•	woe – Peso da evidência (Weight of Evidence), calculado com o logarítimo natural de odds.

•	iv – Valor da informação (Information Value) - woe * (pe_0 – pe_1)





Para facilitar a interpretação dos resultados, tome-se em consideração os seguintes critérios:

Se o IV é  menor que 0.03 então o poder preditivo é = "Não preditivo"

Se o IV está de 0.3 para  0.1 então o poder preditivo é = "Moderadamente preditivo"

Se o IV está de  0.1 para 0.3 então o poder preditivo é = "Medianamente preditivo"

Se o IV é maior que  > 0.3 então o poder preditivo é = "Altamente preditivo"



```r
(
stat<-ExpCatStat(rcl_dataset,Target="decisao",Label="Decisões",result = "Stat",clim=15,Pclass="procedente")
)
```



## Fluxo dos processo

O gráfico abaixo mostra o fluxo dos processos tomando em conta cada uma das variáveis. Cada linha, roxa ou laranja, representa uma reclamação. A cor laranja representa o conjunto dos pedidos procedentes, a cor roxa representa o conjunto dos pedidos improcedentes. As variáveis foram ordenadas conforme a frequência com que decidem favoravelmente ou desfavoravelmete. 

Da visualização, é possível observar que as decisões colegiadas, i.e. decisões dos agravos, são maiormente improcedentes. Com efeito, do total, 1884 decisões colegiadas foram improcedentes e apenas 51 foram procedentes. Uma vez que essas decisão são regularmente proferidas ante de uma irresignação contra uma decisão monocrática, é possível afirmar com tranquilidade nesse caso, e não precisaríamos de qualquer teste estatístico para concluir isso, que as decisões colegiadas assumem papel nitidamente homologatório das decisões monocráticas.

Por outro lado, os ministros Alexandre de Moraes, Gilmar Mendes e Marco Aurélio lideram entre aqueles que mais concedem pedidos. Houve mais concessões após o CPC 2015 e a justiça do trabalho é aparentemente a mais resistente. Por sua vez, as reclamações contra supostas violações de súmulas não são tão bem sucedidas quanto as reclamações contra supostas violações de recursos extraordinários e decisões interpartes.



```r
knitr::include_graphics("https://apps.consudata.com.br/shiny/gg_alluvial.png")
```

A tabela abaixo mostra as diferenças entre os órgãos julgadores em números




