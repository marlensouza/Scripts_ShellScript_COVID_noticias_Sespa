#!/bin/bash
#
# noticia_oficial_Sespa_covid.sh
#
# Autor: Marlen Souza
#
# Descrição: Selecionar links de fontes oficiais para
#            acompanhar noticias dobre o CORONA VIRUS (COVID-19)
#
# Criado: 22/03/2020
#

# Função responsável por acessar site da SESPA via CURL no Endereço www.saude.pa.gov.br.
func_curl_sespa(){

    curl -s http://www.saude.pa.gov.br/category/noticias/page/[0-9]/

}

var_func_curl_sespa=$(func_curl_sespa)

# Função tem a finalidade de filtrar conteúdo via expressão regular com EGREP, selecionando apenas os links relevante.
func_sespa(){

    echo "$var_func_curl_sespa" | egrep -v "(\.(jpg|png)|\/feed\/)$" | egrep "\/[0-9]{4}\/[0-9]{2}\/[0-9]{2}\/" | egrep -o ".*title\=.*" | tr -d "\t" | tac | sed "s/<a href\=\"//;s/\".*//" | nl | sed "s/^ *//;s/\t/=/"

}

var_func_sespa=$(func_sespa)

# Usa a saída da função func_sespa() para gerar uma lista/menu com título das respectivas notícias.
func_titulo_materia(){

    echo "$var_func_curl_sespa" | egrep -v "(\.(jpg|png)|\/feed\/)$" | egrep "\/[0-9]{4}\/[0-9]{2}\/[0-9]{2}\/" | egrep -o ".*title\=.*" | tr -d "\t" | tac | egrep -o "title=\".*\"" | tr -d "\"" | cut -d " " -f 3- | nl
}

var_func_titulo_materia=$(func_titulo_materia)

# Acessa API para gerar dados sobre o corona virus(COVID-19) do ponto de vista mundial.
# jq é o responsável por tratar os dados de saída da API no formato JSON.
func_api_covid_19(){

   curl -s https://coronavirus-tracker-api.herokuapp.com/v2/locations

}

# Função acessa página da SESPA no Twiiter
func_twitter_sespa(){

  curl -s https://twitter.com/SespaPara

}

var_func_twitter_sespa=$(func_twitter_sespa)

# Função filtra número de infectados por Covid-19 no PARÁ
func_numero_casos_covid_pa(){

      echo "$var_func_twitter_sespa" | egrep -o "(há [0-9]{2}.*Covid-19)" | head -n 1 | cut -d " " -f 2

}

var_func_numero_casos_covid_pa=$(func_numero_casos_covid_pa)

var_func_api_covid_19=$(func_api_covid_19)

# A função func_atualização_automatica_id_api() tem por finalidade atualizar de forma automatica o id do pais, caso haja alguma alteração na API.
func_atualização_automatica_id_api(){

   pais="brazil"
   echo "$var_func_api_covid_19" | jq . | egrep -B 1 -i "$pais" | tr -d "( |,$)" | head -n 1 | cut -d : -f 2

}

id_api=$(func_atualização_automatica_id_api)

# Dados mundiais COVID-19
func_dado_mundial(){

    echo "$var_func_api_covid_19" | jq '{"casos_confirmados": ."latest"."confirmed" , "mortes": ."latest"."deaths" , "recuperados": ."latest"."recovered"}' | egrep -v "(^\{|^\})" | tr -d "\"" | tr -d "\,"

}

var_func_dado_mundial=$(func_dado_mundial)

# Dados do Brasil COVID-19
func_dado_brasil(){

    echo "$var_func_api_covid_19" | jq --argjson id_api $id_api '{ "pais": ."locations"[$id_api]."country" , "atualizacao": ."locations"[28]."last_updated" , "confirmados": ."locations"[28]."latest"."confirmed" , "recuperados": ."locations"[28]."latest"."recovered" , "mortes": ."locations"[28]."latest"."deaths" }' | egrep -v "(^\{|^\})" | tr -d "\"" | tr -d "\," | tr -d "\"" | tr -d "\," | sed "s/T.*//"

}

var_func_dado_brasil=$(func_dado_brasil)

func_num_linhas(){

    echo "$var_func_sespa" | tail -n 1 | cut -d = -f 1

}


func_main(){
echo "
   SESPA (www.saude.pa.gov.br)
   E-MAIL: ouvidoria@sespa.pa.gov.br
   TELEFONES: (91) 3222-4184 / 3212-5000, Discagem gratuita: 0800-280 9889.
   Twitter https://twitter.com/SespaPara

           $(date +%d/%m/%Y)

Dados mundiais COVID-19:
$var_func_dado_mundial

Dados Brasil COVID-19:
$var_func_dado_brasil

Dados PARÁ COVID-19:
  Infectado: $var_func_numero_casos_covid_pa
  
"

# Título/menu
func_titulo_materia

echo -n "
Quanto maior o valor de índice,
mais recente é a notícia.

Digite o número da notícia: "

# Recebe a opção/número e instância a variável número
read numero

# Gera link da notícia
link_noticia=$(echo "$var_func_sespa" | egrep "^$numero=" | sed "s/^$numero=//")

# Exibe link selecionado no menu.
echo "
Link da notícia selecionada:
$link_noticia
"
# Executa navegador para acessar link contido na váriavel de ambiente $link_noticia. O navegador pode ser
# alterado por qualquer outro, batando assim substituir a "google-chrome" por qualquer outro navegador.

linhas=$(func_num_linhas)

if test "$numero" -gt "$linhas" || test "$numero" -le 0
then
  echo "opção não existe!"
else
  google-chrome $link_noticia
fi

}

while :
do
  echo -e '\033c'
  # Executa função func_main() suprimindo saídas de erro com o "2>&-"
  func_main 2>&-
  read -p "Deseja continuar (s/n)? "
  [[ ${REPLY^} == N ]] && exit
done
