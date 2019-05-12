# Transformação 

## Delimitação do escopo

Na presente demonstração, iremos analisar as decisões de mérito do Supremo Tribunal Federal em casos com trânsito em julgado sobre pedidos de reclamação contra órgãos jurisdicionais entre os anos de 2011 e 2018, com exceção daquelas que versam sobre a competência do STF. Para realizar esse filtro, é necessária a utilização tanto de automação, vez que são mais de 22 mil processos, como também de métodos manuais, para aqueles casos em que a automação não for suficiente para extrair as informações relevantes.

Sobre o uso de métodos automatizados de mineração e classificação de texto, observa-se que textos, nesse caso, decisões judiciais, são dados não estruturados. Com os avanços dos processos de automação na leitura e extração de dados, bem como, dos processos de classificação por meio do uso de inteligência artificial (deep learning), surgiram possibilidades de análise que antes não eram possíveis.

No entanto, o uso de computação para ler e classificar textos está longe de atingir a qualidade do processo humano. Como bem afirmam [@grimmer2013text], os métodos quantitativos de classificação de texto apenas ampliam a atividade humana, não a substituem. Além disso, não existe um método global de análise automatizada. Por fim, a classificação automatizada deve ser posteriormente validada por meio de revisão humana. A técnica adotada é tirar uma amostra de algumas dezenas de casos e submeter à leitura humana para verificar se houve erros e, em caso afirmativo, se o número é muito grande.

## Remoção dos casos que não serão analisados.

Primeiramente iremos remover três grupos de casos. Aqueles que não transitaram em julgado no momento da análise, aqueles que correm em segredo de justiça e aqueles cujo reclamado não é órgão judicial. A informação sobre o trânsito em julgado se encontra no andamento. A informação sobre o segredo de justiça se encontra nos detalhes.


```r
transitado <- andamentos %>% 
  filter(str_detect(titulo,"(?i)transitado")) %>% 
  pull("incidente") %>% 
  unique()

publico <- detalhes %>% 
  filter(!str_detect(sigilo,"Segredo de Justiça")) %>% 
  pull("incidente") %>% 
  unique()
```

Para manter somente os casos em que o reclamado é órgão judicial, utilizaremos a função `classify_respondent()` do pacote `stf` . Além de excluir os casos em que o respondente não é órgão judicial, ela classifica o órgão judicial conforme a instância e o segmento do Poder Judiciário ao qual pertence.

A classificação é bem sucedida na maioria dos casos, porém restaram algumas ambiguidades, relacionadas aos conselhos superiores dos tribunais de justiça, que ora decidem jurisdicionalmente, ora administrativamente. 


```r
partes <- stf::classify_respondent(partes)

remover_conselhos <- conselhos %>%
  select(c(1,4,5)) %>%
  slice(38:57) %>%
  setNames(c("reclamados","incidente","acao")) %>%
  filter(acao=="EXCLUIR")


remover_conselhos[2,1]<-"CONSELHO DA MAGISTRATURA DO TRIBUNAL DE JUSTIÇA DO ESTADO DO RIO GRANDE DO SUL"

partes <- partes %>%
  dplyr::filter(!is.element(incidente,remover_conselhos$incidente),!is.element(reclamado,remover_conselhos$reclamados))

partes <- partes %>%
  filter(instancia!="outros") %>%
  filter(segmento!="outros")
```

Por fim, verificamos que na base andamentos há movimentações que foram invalidadas. A função de leitura dos andamentos cria uma coluna indicando se a movimentação foi invalidada ou não. O que temos de fazer é simplesmente remover tais linhas da base andamentos.


```r
andamentos <- andamentos %>% 
  filter(!invalido)
```


## Baixar textos das decisões

Para baixar os textos das decisões, criamos duas funções, uma que baixa os textos em rtf, outra que baixa os textos em pdf. As urls dos textos estão contidas na base andamentos. Acontece que nem todos os textos se referem a decisões de mérito. Alguns são pareceres do Ministério Público, outros são meros despachos, outros são decisões interlocutórias ou apreciação de liminar ou cautelar. 
No entanto, a base andamento nem sempre é suficientemente informativa a respeito. Por essa razão, optamos por baixar todos os textos e, posteriormente, realizar as exclusões.


```r
dir.create("textos_rtf")
dir.create("textos_pdf")
stf::download_stf_pdf(andamentos,"textos_pdf")
stf::download_stf_rtf(andamentos,"textos_rtf")

textos_rtf <- stf::read_stf_rtf("textos_rtf")
textos_pdf <- stf::read_stf_pdf("textos_pdf")
texto <- bind_rows(textos_rtf,textos_pdf)
```

## Limpeza dos textos
Os textos das decisões são usados para identificar casos que devem ser excluídos. Por exemplo, processos em que não houve decisão de mérito, tais como decisões terminativas sem julgamento de mérito, processos extintos e prejudicados, seja por inércia da parte, seja por perda do objeto.

Além disso, a decisão contida na base acervo nem sempre corresponde à real decisão sobre reclamação, pois os técnicos do STF simplesmente extraem a última decisão do andamento, a qual por vezes é um mero despacho. Igualmente, o título do andamento nem sempre são suficientemente descritivos. Alguns deles apenas indicavam que se tratatava de uma publicação no diário de justiça.

Por essa razão, optou-se por extrair dos próprios textos a parte que corresponde à decisão, isto é, extraímos os últimos 800 caracteres do texto, que provavelmente contêm a decisão.  Antes, porém, excluímos do texto as informações sobre quem assinou o documento.

Ademais, cortamos essa parte a partir de palavras-chave tais como ex positis, diante do exposto etc. Com isso, foi possível verificar se a decisão se tratava de liminar ou cautelar, se era um mero despacho concedendo vista ou uma cerdidão. Algumas palavras no início do texto indicavam se ele era um parecer do MP, se era um embargo de declaração ou se era um agravo regimental. Quando não foi possível identificar no início, foi possível fazê-lo no final do texto.

Alguns embargos foram convertidos em agravo regimental. A identificação desses casos também foi necessária.


```r
texto <- texto %>%
  unite("docname",extensao,docid,sep="") %>%
  inner_join(andamentos,by="docname")

texto <- texto %>%
  mutate(caracteres=nchar(texto))


texto <- texto %>%
  mutate(texto=str_remove_all(texto,"(?i)documento assinado\\X+?(sob|por)\\s\\w+"))


texto <- texto %>%
  mutate(texto = str_squish(texto))



texto <- texto %>%
  mutate(dispositivo = case_when(
    caracteres > 800 ~{
      stringi::stri_reverse(texto) %>%
        stringi::stri_extract_first_regex("\\X{800}") %>%
        stringi::stri_reverse()
    },
    TRUE ~ texto))



texto <- texto %>%
  mutate(dispositivo=case_when(
    str_detect(texto1,"(?i)(antes? o exposto|ex positis|diante disso|ante o quadro|pelo exposto|diante do exposto|nesse contexto|diante do contexto|por es[st]a razão|pelas razões expostas|por todo o exposto|dessa forma|decis.o:|com essas considerações|nessas condições|sendo assim|face ao exposto|do exposto)") ~{
      str_extract(dispositivo,"(?i)(antes? o exposto|ex positis|diante disso|ante o quadro|pelo exposto|diante do exposto|nesse contexto|diante do contexto|por es[ts]a razão|pelas razões expostas|por todo o exposto|dessa forma|decis.o:|com essas considerações|nessas condições|sendo assim|face ao exposto|do exposto).+")
    },
    TRUE ~ dispositivo))


texto <- texto %>%
  filter(!str_detect(dispositivo,"(?i)defiro a liminar"))

texto <- texto %>%
  mutate(exclusoes = str_extract(texto,"\\X{80}")) %>%
  # filter(!str_detect(cautelar,"MEDIDA CAUTELAR")) %>%
  filter(!str_detect(exclusoes,"(?i)(^Documento|^MINISTÉRIO|^procurador)")) %>%
  filter(!str_detect(exclusoes,"EMB.DECL.")) %>%
  filter(!str_detect(doc,"(?i)(PGR|despacho|certid.o|vista)")|is.na(doc)) %>%
  select(-exclusoes)
```

## Classificação dos textos conforme procedência ou improcedência

O procedimento abaixo classifica os textos das decisões conforme procedência ou improcedência. O trabalho aqui foi recortar as decisões que eram de mérito. Para tanto, aplicamos a técnica de expressões regulares (regex) para identificar padrões nos textos dos dispositivos. 

Todo esse trabalho de identificação é heurístico e requer a conjunção de esforços de automação e validação pelo pesquisador. Uma técnica de processamento de linguagem natural muito útil é conhecida como "kwic" (key word in context). Por ela, buscamos uma palavra-chave, e.g., "procedente" em seu contexto, isto é, verificamos todas as vezes que esta palavra aparece no dispositivo e quais as palavras que a antecedem ou que a sucedem. Este procedimento permite observar padrões tais como "não procedente" ou "julgo procedente". A experiência com classificações em outras pesquisas tem nos permitido reduzir significativamente as chances de erro.

Mesmo quando ocorrem alguns erros, esses são mínimos e podem ser verificados por outros meios, tais como a verificação da consistência da base. Por exemplo, um texto erroneamente classificado como decisão de agravo deve ser contrastado com o tipo de decisão. Se esta foi uma decisão monocrática, claramente não se trata de um agravo. 

Por fim, uma particularidade  do STF é o uso da expressão "nego seguimento" ora par indicar "improcedência", ora para indicar uma decisão terminativa sem julgamento do mérito. Esse aspecto representou uma dificuldade a mais, pois foi necessário encontrar outras palavras que indicassem quando a expressão estava sendo usada para julgamento de mérito, e.g. "aderência" ou quando definitivamente não era de mérito, e.g, "súmula 734" ou "sucedâneo" e "atalho".

Diante da dúvida se a decisão era de mérito ou não, preferiu-se excluí-la. Ao final, depois de todas as exclusões e aplicações de filtros, chegou-se a 5636 casos. Uma amostra foi retirada para realização de validação humana. Não foi identificado nenhum erro. Isso não signfica que a base está isenta de erros de classificação, mas a pesquisadora está segura de que se estes ocorreram, eles foram mínimos e não afetarão significativamente os resultados.

Ainda assim, a próxima etapa da análise, denominada "Exploratory Data Analysis" permite verificar inconsistências ou disparidades nas distribuições e anomalias nos dados. Novas correções são possíveis nesse momento.




```r
texto <- texto  %>%
  dplyr::mutate(decisao = stringi::stri_trans_tolower(dispositivo),
                decisao = abjutils::rm_accent(decisao),
                decisao = case_when(
                  str_detect(decisao,"(nego|negado|negou)\\sseguimento") ~ "nego seguimento",
                  str_detect(decisao,"(desprov\\w+|improv\\w+|improced\\w+)") ~ "improvido",
                  str_detect(decisao,"(nao|nega\\w+)\\s+provi.*")~ "improvido",
                  str_detect(decisao,"(rejeit\\w+|inadmitidos?)") ~ "improvido",
                  str_detect(decisao,"mantiveram") ~ "improvido",
                  str_detect(decisao,"(acolho|acolhido)") ~ "provido",
                  str_detect(decisao,"(deram|da\\-*\\s*se|dando\\-*(se)*|comporta|dou|confere\\-se|se\\s*\\-*da|merece)\\sprovi\\w+") ~ "provido",
                  str_detect(decisao,"parcial\\w*\\sprovimento") ~ "provido",
                  str_detect(decisao,"(nao\\sderam|nao\\smerece|se\\snega|nega\\-*\\s*se|negar\\-*\\s*lhe|nao\\scomporta|negram|negararam|nego|negar|negou)") ~ "improvido",
                  str_detect(decisao,"\\bprovimento") ~ "provido",
                  str_detect(decisao,"\\bprocedente") ~ "provido",
                  str_detect(decisao,"(nao\\sconhec\\w+|nao\\sse\\sconhec\\w+)") ~ "não conhecido",
                  str_detect(decisao,"desconh\\w+") ~ "desconhecido",
                  str_detect(decisao,"nao\\s+conhec\\w+") ~ "desconhecido",
                  str_detect(decisao,"(homolog|desistencia)") ~ "desistência",
                  str_detect(decisao,"diligencia") ~ "conversão em diligência",
                  str_detect(decisao,"sobrest") ~ "sobrestado",
                  str_detect(decisao,"prejudicad\\w*") ~ "prejudicado",
                  str_detect(decisao,"(anular\\w*|nulo|nula|nulidade)") ~ "anulado",
                  TRUE ~ "outros"))

texto <- texto %>%
  mutate(decisao = case_when(
    decisao == "provido" ~ "procedente",
    decisao == "improvido" ~ "improcedente",
    TRUE ~ decisao
  ))

improcedente <- texto %>%
  filter(decisao == "improcedente")

procedente <- texto %>%
  filter(decisao == "procedente")

seguimento <- texto %>%
  filter(decisao=="nego seguimento")


prejudicado<-texto %>%
  filter(decisao=="prejudicado/extinto")

sobrestado <- texto %>%
  filter(decisao=="sobrestado")


outros <- texto %>%
  filter(decisao=="outros")


sucedaneo <- seguimento %>%
  select(texto,docname) %>%
  quanteda::corpus("docname","texto") %>%
  quanteda::kwic("(?i)(suced[aâ]neo|\\bpresta\\b|atalho)",window = 20,valuetype = "regex") %>%
  as_tibble()

sucedaneo<-sucedaneo %>%
  filter(keyword!="presta-se") %>%
  pull("docname") %>%
  unique()

seguimento <- seguimento %>%
  filter(!docname %in% sucedaneo)


sumula_734 <- seguimento %>%
  filter(str_detect(texto,"\\b734\\b")) %>%
  pull("docname") %>%
  unique()

seguimento <- seguimento %>%
  filter(!docname %in% sumula_734)

aderencia <- seguimento %>%
  select(texto,docname) %>%
  quanteda::corpus("docname","texto") %>%
  quanteda::kwic("(?i)ader.ncia",window = 20,valuetype = "regex") %>%
  as_tibble()
```

