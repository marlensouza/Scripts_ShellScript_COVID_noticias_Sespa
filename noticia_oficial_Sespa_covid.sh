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

# Usa a saída da função func_sespa() para gerar uma lista/menu com título e timestamp da respectiva notícia.
func_titulo_materia(){

    func_sespa | cut -d / -f 4- | sed "s/\/$//" | sort |egrep -o "([0-9]{4}.*|\/.*)" | sed "s/^\///"| nl | sed "s/^ *//;s/\t/ /"
}

# Acessa API para gerar dados sobre o corona virus(COVID-19) do ponto de vista mundial.
# jq é o responsável por tratar os dados de saída da API no formato JSON.
func_dado_mundial(){

    curl -s https://coronavirus-tracker-api.herokuapp.com/v2/locations | jq '{"casos_confirmados": ."latest"."confirmed" , "mortes": ."latest"."deaths" , "recuperados": ."latest"."recovered"}' | egrep -v "(^\{|^\})" | tr -d "\"" | tr -d "\,"

}

# Acessa API para gerar dados sobre o corona virus(COVID-19) no BRASIL.
# jq é o responsável por tratar os dados de saída da API no formato JSON.
func_dado_brasil(){

    curl -s https://coronavirus-tracker-api.herokuapp.com/v2/locations | jq '{ "pais": ."locations"[35]."country" , "atualizacoes": ."locations"[35]."last_updated" , "confirmados": ."locations"[35]."latest"."confirmed" , "recuperados": ."locations"[35]."latest"."recovered" , "mortes": ."locations"[35]."latest"."deaths" }' | egrep -v "(^\{|^\})" | tr -d "\"" | tr -d "\,"

}


echo " 
   SESPA (www.saude.pa.gov.br)

           $(date +%d/%m/%Y)
           
Dado munial:
$(func_dado_mundial)

Dado Brasil:
$(func_dado_brasil)
"


func_titulo_materia

echo -n "
Digite o número da noticia: "
read numero

link_noticia=$(func_sespa2 | egrep "^$numero=" | sed "s/^$numero=//")

google-chrome $link_noticia

func_titulo_materia
