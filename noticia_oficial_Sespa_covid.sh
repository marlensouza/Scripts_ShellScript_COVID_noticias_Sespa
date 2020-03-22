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

func_sespa2(){
    
    curl -s http://www.saude.pa.gov.br/category/noticias/page/[0-5]/ | egrep -i "(covid|corona|gripe)" | egrep -o "\http\:.*\/" | sed "s/\".*//g" | sort | uniq | egrep -v "\/feed\/$" | nl | sed "s/^ *//;s/\t/ /" | tr " " "=" | egrep -v "\.jpg$"

}

func_titulo_materia(){

    func_sespa2 | cut -d / -f 4- | sed "s/\/$//" | sort |egrep -o "([0-9]{4}.*|\/.*)" | sed "s/^\///"| nl | sed "s/^ *//;s/\t/ /"
}

echo " 
   SESPA (www.saude.pa.gov.br)

           $(date +%d/%m/%Y)
"


func_titulo_materia

echo -n "
Digite o número da noticia: "
read numero

link_noticia=$(func_sespa2 | egrep "^$numero=" | sed "s/^$numero=//")

google-chrome $link_noticia

func_titulo_materia
