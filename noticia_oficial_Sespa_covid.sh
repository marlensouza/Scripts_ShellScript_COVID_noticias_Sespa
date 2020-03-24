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

# Função responsável por acessar site da SESPA via CURL no Endereço www.saude.pa.gov.br e filtrar conteúdo via expressão regular
# com EGREP usanso como parâmetros de expressões regulares as seguintes ocorrências "(covid|corona|gripe)".

func_sespa(){

    curl -s http://www.saude.pa.gov.br/category/noticias/page/[0-5]/ | egrep -i "(covid|corona|gripe)" | egrep -o "\http\:.*\/" | sed "s/\".*//g" | sort | uniq | egrep -v "\/feed\/$" | nl | sed "s/^ *//;s/\t/ /" | tr " " "=" | egrep -v "\.jpg$"

}

var_func_sespa=$(func_sespa)

# Usa a saída da função func_sespa() para gerar uma lista/menu com título e timestamp da respectiva notícia.
func_titulo_materia(){

    echo "$var_func_sespa" | cut -d / -f 4- | sed "s/\/$//" | sort |egrep -o "([0-9]{4}.*|\/.*)" | sed "s/^\///"| nl
}

var_func_titulo_materia=$(func_titulo_materia)

# Acessa API para gerar dados sobre o corona virus(COVID-19) do ponto de vista mundial.
# jq é o responsável por tratar os dados de saída da API no formato JSON.
func_dado_mundial(){

    curl -s https://coronavirus-tracker-api.herokuapp.com/v2/locations | jq '{"casos_confirmados": ."latest"."confirmed" , "mortes": ."latest"."deaths" , "recuperados": ."latest"."recovered"}' | egrep -v "(^\{|^\})" | tr -d "\"" | tr -d "\,"

}

var_func_dado_mundial=$(func_dado_mundial)

# Acessa API para gerar dados sobre o corona virus(COVID-19) no BRASIL.
# jq é o responsável por tratar os dados de saída da API no formato JSON.
func_dado_brasil(){

    curl -s https://coronavirus-tracker-api.herokuapp.com/v2/locations | jq '{ "pais": ."locations"[35]."country" , "atualizacao": ."locations"[35]."last_updated" , "confirmados": ."locations"[35]."latest"."confirmed" , "recuperados": ."locations"[35]."latest"."recovered" , "mortes": ."locations"[35]."latest"."deaths" }' | egrep -v "(^\{|^\})" | tr -d "\"" | tr -d "\," | tr -d "\"" | tr -d "\," | sed "s/T.*//"

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
"

# Título/menu
func_titulo_materia

echo -n "
Quanto maior o valor de índice, 
mais recente é a notícia.

Digite o número da noticia: "

# Recebe a opção/número e instância a variável número
read numero

# Gera link da notícia
link_noticia=$(func_sespa | egrep "^$numero=" | sed "s/^$numero=//")

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
