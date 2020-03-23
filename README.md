# Scripts_ShellScript_COVID_noticias_Sespa

Tem por finalidade oferecer de forma imediata notícias do site da SESPA via ShellScrip no Termianl Linux.


- Google-chrome é pré requisito. Mas pode ser alterado no script.
- Para que a API funcione, é necessário que esteja instaldo o [jq](https://stedolan.github.io/jq/). 

```
sudo apt install jq
``` 
- [API](https://coronavirus-tracker-api.herokuapp.com/v2/locations)
- Uso:
```
$ chmod +x noticia_oficial_Sespa_covid.sh
$ ./noticia_oficial_Sespa_covid.sh
```


![](./imagem.png)
