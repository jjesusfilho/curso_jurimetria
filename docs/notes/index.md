---
title: "Introdução à jurimetria com o R"
cover-image: ""
author: "José de Jesus Filho"
date: "Última atualização: 12/mai/2019"
site: bookdown::bookdown_site
output: 
  bookdown::gitbook:
    config:
      toc:
        collapse: subsection
        scroll_highlight: yes
      fontsettings:
        theme: white
        family: serif
        size: 1
    split_by: section+number
    highlight: tango
    includes:
      in_header: [header_include.html]
      before_body: open_review_block.html
always_allow_html: yes
documentclass: book
bibliography: [biblio.bib, packages.bib]
biblio-style: apalike
biblatexoptions:
  - sortcites
link-citations: yes
github-repo: "jjesusfilho/jurimetria"
description: "Introdução à jurimetria para acadêmicos e profissionais do direito"
url: 'https://jjesusfilho.github.io/jurimetria/'
tags: [Métodos, Jurimetria, Estatística, Machine learning,Causalidade, programação em R, Direito]
---
















# Prefácio {-}

A principal motivação em escrever este livro tem sido incentivar estudantes de direito a realizar pesquisas empíricas quantitativas. A psicologia desenvolveu a psicometria e a economia desenvolveu a econometria, cada uma com objeto e métodos próprios. Cabe ao jurista assumir a tarefa de desenvolver métodos quantitativos próprios para análise da prática do direito, seja nas cortes, nos escritórios de advocacia, nos departamentos jurídicos das empresas ou ongs e mesmo do direito achado na rua.

Minha expectativa é a de que, não somente as faculdades de direito criem as respectivas cadeiras de jurimetria, mas também as escolas da magistratura, do Ministério Público, da Defensoria Pública e das procuradorias dos estados, incorporem a jurimetria como parte da formação de seus profissionais.

Até pouco mais de dez anos, a jurimetria, enquanto campo específico de estudo, era praticamente desconhecida. Foi o trabalho pioneiro do professor Marcelo Guedes Nunes, ao defender em 2012 sua tese de doutorado sobre o tema e criar a Associação Brasileira de Jurimetria, que esta disciplina ganhou fôlego a passou a ser disseminada.


#### Convenções neste livro {-}

+ *Itálico* novos termos, nomes, botões e similares.

+ <tt>Texto com largura constante</tt> geralmente usado em parágrafos para indicar o código <tt>R</tt>. Isso inclui comandos, variáveis, funções, tipos de dados, bases e nomes de arquivos.

+ <code>Texto com largura constante em fundo cinza</code> indica <tt>R</tt> código que foi digitado literalmente por você. Pode parecer em parágrafos para melhor distinção entre códigos executáveis e e não executáveis, mas será encontrado principalmente em forma de blocos largos  de  códig <tt>R</tt>. Esses blocos são referidos como trechos de códigos (code chunks). 

#### Agradecimentos {-}

Devo muito à minha esposa Melissa, não somente pelo constante incentivo, mas também pelos frequentes conselhos sobre como conduzir o meu trabalho.

Aos colegas da Associação Brasileira de Jurimetria (ABJ), especialmente ao Julio Trecenti, por haver me introduzido à jurimetria e, com isso, resgatar a minha paixão adolescente por exatas a fim de aplicá-la ao direito.

Os professores Marcos e Lorena Barbiera me iniciaram no mundo dos métodos quantitativos. A eles um especial agradecimento.  O ambiente colaborativo da comunidade do <tt>R</tt> foi terra fecunda onde plantei as sementes que hoje geram este e tantos outros frutos open source.

<br>
![Creative Commons License](https://mirrors.creativecommons.org/presskit/buttons/88x31/svg/by-nc-sa.eu.svg)

This book is licensed under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/).

# Introdução {-}

<hr style="background-color:#3C6690;height:2px">

Este livro está voltado ao estudante de direito de graduação ou pós-graduação. Ele não pressupõe conhecimento prévio de métodos quantitativos e conhecimento de matemática que vá além do aprendido no ensino médio. O objetivo é introduzir ao estudante a metodologia quantitativa e é proeminentemente conceitual. Demonstrações de teoremas e derivações matemáticas, quando existirem, serão incluídas nos apêndices. Pretendemos que esta seja uma leve introdução  aos métodos quantitativos de pesquisa empírica no direito. Mas isso não significa que flexibilizaremos o rigor na explanação dos conceitos em favor da didática. Um cuidado especial será tomado para conciliar essas duas exigências.

Além de ser uma obra voltada a estudantes de direito, o livro possui alguns diferenciais em relação ao que tem sido produzido até o momento. Passo a apontá-los. 

Primeiramente, ao contrário da maioria das obras jurídicas este livro, em sua versão eletrônica, é inteiramente gratuito, disponibilizado via web, com passibilidade de ser baixado para versões epub ou pdf, igualmente gratuitas. Todos as situações reais apresentadas serão provenientes da experiência do autor no âmbito do direito, seja de suas pesquisas, seja de pessoas por ele auxiliadas no mestrado ou no doutorado.

O livro não somente oferece os tópicos típicos de introdução à métodos quantitativos, mas inclui também alguns tópicos de processamento de linguagem natural, os quais permitem ao pesquisador analisar dados não estruturados, como decisões judiciais, petições e pareceres técnicos.

O terceiro diferencial deste livro é que ele ensina a programar em <tt>R</tt>, ou seja, o estudante irá não somente aprender as técnicas de métodos quantitativos, como também irá colocá-las em prática enquanto estuda. Poderá testar o aprendizado no âmbito do próprio livro e saber se acertou ou errou no mesmo momento.

O livro foi organizado a partir da experiência do autor como pesquisador, como professor e orientador de estudantes de direito. Metodologia nunca foi um assunto adequadamente tratado nos cursos de direito. Na maioria das faculdades, a disciplina reduz-se a ensinar o passo a passo da redação do trabalho de conclusão de curso.

Metodologia tem sido mais bem um curso sobre como redigir o trabalho de conclusão de curso do que propriamente familiarizar os alunos com ferramentas para a pesquisa empírica ou mesmo teórica. Consequência disso é que muitos partem para o mestrado com questões relevantes a serem pesquisadas, mas sem noção alguma de como converter suas questões em hipóteses teóricas e operacionalizá-las em variáveis concretas. 

Muitos terminam por reduzir seu trabalho à discussão hermenêutica, ou quando se arriscam a levantar dados quantitativos, apresentam os resultados sem qualquer rigor metodológico ou, o que é pior, vão a campo, coletam dados e tentam identificar possíveis correlações ou associações.

A partir desses dilemas, a proposta do presente livro é instrumentalizar o pesquisador do direito para conduzir pesquisas válidas, confiáveis, reproduzíveis, replicáveis e robustas. Para tanto, o livro seguirá o seguinte roteiro.

Inicialmente trataremos do desenho de pesquisa, ou seja, como passar do problema da pesquisa para a construção de uma teoria causal, da elaboração de hipóteses teóricas que expliquem as relações entre causa e efeito, da operacionalização dessas hipóteses teóricas em variáveis concretas as quais possam medir o quanto um fator influencia o resultado. Uma decisão, ainda que provisória, seria eleger o modelo estatístico utilizado para testar as hipóteses declaradas, mas essa tarefa será colocada mais adiante, quando adentrarmos nos métodos quantitativos propriamente ditos. 

Em seguida, passaremos a trabalhar com os objetos a serem medidos e sua categorização. A pergunta-guia dessa parte será: O que o pesquisador do direito pode medir e como fazê-lo? Aprenderemos sobre os níveis de mensuração e suas escalas. Há valores que são categóricos, tais como mulher e homem ou religião: cristão, judeu, mulçumano. Há valores que são contáveis, tais como o número de juízes de um Tribunal de Justiça, o número de processos julgados no mês, o número de processos distribuídos. Há valores que são contínuos, por exemplo, os salários dos juízes, promotores e defensores, o tempo de provimento na carreira  e assim por diante.

A seção anterior servirá de base para introduzir o estadante ao ambiente de programação <tt>R</tt>,  a fim de familizarizá-lo com a interação com a máquina por meio da emissão de comandos em vez de interface gráfica. 

O passo seguinte será aplicar o aprendido até aqui para criar um projeto de pesquisa no próprio ambiente <tt>R</tt>. O estudante conhecerá ferramentas úteis para organizar seu projeto de pesquisa, de forma a integrar texto, código e dados num só ambiente e criar mecanismos de controle e validação da pesquisa.

Os próximos capítulos serão dedicados à coleta, importação, limpeza, transformação e disposição dos dados para análise. Alêm das lições, o estudante terá oportunidade de praticar dezenas de exercícios, a fim de solidificar seu aprendizado em <tt>R</tt>. Aprenderá também como criar gráficos a fim de visualizar a distribuição dos dados.

Métodos de análise descritiva e exploratória dos dados serão introduzidos a fim de explorar eficazmente as relações entre as variáveis explicativas e a variável resposta.

Os capítulos seguintes serão devotados a introduzir o estudante os modelos estatísticos mais comuns de análise de dados, tais como modelos lineares, modelos lineares generalizados, séries temporais, modelos mistos e modelos com dados em painel.











