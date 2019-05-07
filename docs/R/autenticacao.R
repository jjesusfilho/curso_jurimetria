library(shiny)
library(jose)
library(httr)
library(jsonlite)
library(stringi)
### Autenticacao ####

## Esta função irá verificar se código pedido está presente na url de retorno.
has_auth_code <- function(params) {
  
  return(!is.null(params$code))
}


audiencia<-"https://meudominio.auth0.com/api/v2/"

state<-stringi::stri_rand_strings(1,15) %>%  ## Cria uma string aleatória para assegurar que a resposta do auth0 se refere a esta requisição.
  jose::base64url_encode() ## Ela precisa estar em base64url.

client_secret<- Sys.getenv("AUTH0_SECRET")
scope = "openid" 

redirect_uri = "url para callback" ## URL que você coloca no Allowed Callback URLs quando cria a aplicação. Pode ser algo como: https://exemplo.com.br/shiny/meu_app/


response_type = "code" ## Você deve pedir um código para o auth0. Ele virá junto com o state na url resposta. Com isso, você 
## verifica se o state é o mesmo que você enviou.


url<- "https://dominio.auth0.com/authorize" ## Este é o seu domínio no auth0 seguido pelo parâmetro authorize, que corresponde à api de pedido do código.

### Com todas essas informações, você monta a url (u) para solicitar.
query = list(state = state, 
             client_id = Sys.getenv("AUTH0_CLIENT"),
             protocol = "oauth2", 
             prompt = "", 
             response_type = "code",
             connection = "Username-Password-Authentication", 
             redirect_uri = redirect_uri, 
             scope = "openid")
## Provisório, substituir mais adiante pelo
u<-httr::parse_url(url)
u$query<-query
u<-httr::build_url(u)






autorizacao<-function(x){
  u
}


ui <- fluidPage(
  ## Aqui vai sua ui como qualquer outra.
  verbatimTextOutput("texto")
)

## Esta função irá rodar antes do ui. Ela vai verificar se na resposta (na url) do auth0 está o código "code" solicitado.
## Na resposta também vem o state. Você pode comparar com o state que você enviou para ver se ele é o mesmo. Assim, você está seguro de que 
## é o próprio auth0 que está respondendo.
## Se a resposta vier conforme esperado, roda o ui.
uiFunc<-function(x){
  if(!has_auth_code(parseQueryString(x$QUERY_STRING))){
    return(tags$script(HTML(sprintf("location.replace(\"%s\");", u))))
  }else{
    ui
  }}


