#_______________________________________________________________________________________________________________________
#
# Script para gerar as series a serem mostradas no app
#
#_______________________________________________________________________________________________________________________
#
#_______________________________________________________________________________________________________________________
# inicializacao ----
#_______________________________________________________________________________________________________________________
library(jsonlite)
library(curl)
library(dplyr)
#_______________________________________________________________________________________________________________________
# carregar os dados do INPC ----
#_______________________________________________________________________________________________________________________
# limpar a area de trabalho
rm(list=ls())
# metadados do INPC
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/7063/metadados"
# carregar todos os metadados
inpc <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- inpc$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- inpc$variaveis
# remover o termo INPC das variaveis
variaveis$nome <- gsub("INPC - ","", variaveis$nome)
variaveis <- variaveis[variaveis$id!=45,]
# filtrar as categorias
categorias <- inpc$classificacoes$categorias[[1]]
categorias <- categorias[categorias$id%in%c(7169,7170,7445,7486,7558,7625,7660,7712,7766,7786),]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/7063/localidades/N7%7CN6%7CN1"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar coluna com os estados
localidades$estados <- c("(PA)","(CE)","(PE)","(BA)","(MG)","(ES)","(RJ)","(SP)","(PR)","(RS)","(AC)","(MA)","(SE)","(MS)","(GO)","(DF)","")
# unir as cidades e estados
localidades$nome_loc <- paste(localidades$nome_loc, localidades$estados, sep=" ")
# remover o espaco no nome das localidades
localidades[localidades$id_loc==1,"nome_loc"] <- gsub(" ","",localidades[localidades$id_loc==1,"nome_loc"])
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
               "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar variavel com o ultimo numero de serie inserido manualmente no app
numero_ini <- 100003
# criar lista vazia para armazenar as series
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      if(!(localidades[j,"nome_loc"]=="Brasil"&categorias[w,"nome"]=="Índice geral")){
        numero_ini <- numero_ini+1
        lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                  "Índice Nacional de Preços ao Consumidor (INPC)",
                                                                  "Índice Nacional de Preços ao Consumidor (INPC)",
                                                                  "O INPC tem por objetivo a correção do poder de compra dos salários, através da mensuração das variações de preços da cesta de consumo da população assalariada com mais baixo rendimento. Atualmente, a população-objetivo do INPC abrange as famílias com rendimentos de 1 a 5 salários mínimos, cuja pessoa de referência é assalariada, residentes nas regiões metropolitanas de Belém, Fortaleza, Recife, Salvador, Belo Horizonte, Vitória, Rio de Janeiro, São Paulo, Curitiba, Porto Alegre, além do Distrito Federal e dos municípios de Goiânia, Campo Grande, Rio Branco, São Luís e Aracaju.",
                                                                  "%",
                                                                  "IBGE",
                                                                  paste0("https://servicodados.ibge.gov.br/api/v3/agregados/7063/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=315[",categorias[w,"id"],"]"),
                                                                  1,
                                                                  "mensal",
                                                                  variaveis[i,"nome"],
                                                                  localidades[j,"nome_nivel"],
                                                                  localidades[j,"nome_loc"],
                                                                  categorias[w,"nome"])
      }
    }
  }
}
# transformar em data.frame
teste2 <- do.call("rbind",lista_dados)
teste2 <- as.data.frame(teste2)
# apagar o numero das linhas
row.names(teste2) <- NULL
# exportar como csv
write.csv(teste2, file="C:/Users/Kleber/Documents/inpc.csv", row.names = F)
#_______________________________________________________________________________________________________________________
# carregar os dados do IPCA ----
#_______________________________________________________________________________________________________________________
# metadados do INPC
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/7060/metadados"
# carregar todos os metadados
ipca <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- ipca$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- ipca$variaveis
# remover o termo INPC das variaveis
variaveis$nome <- gsub("IPCA - ","", variaveis$nome)
variaveis <- variaveis[!variaveis$id%in%c(45,66),]
# filtrar as categorias
categorias <- ipca$classificacoes$categorias[[1]]
categorias <- categorias[categorias$id%in%c(7169,7170,7445,7486,7558,7625,7660,7712,7766,7786),]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/7060/localidades/N7%7CN6%7CN1"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar coluna com os estados
localidades$estados <- c("(PA)","(CE)","(PE)","(BA)","(MG)","(ES)","(RJ)","(SP)","(PR)","(RS)","(AC)","(MA)","(SE)","(MS)","(GO)","(DF)","")
# unir as cidades e estados
localidades$nome_loc <- paste(localidades$nome_loc, localidades$estados, sep=" ")
# remover o espaco no nome das localidades
localidades[localidades$id_loc==1,"nome_loc"] <- gsub(" ","",localidades[localidades$id_loc==1,"nome_loc"])
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar variavel com o ultimo numero de serie inserido manualmente no app
numero_ini <- 100513
# criar lista vazia para armazenar as series
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      if(!(localidades[j,"nome_loc"]=="Brasil"&categorias[w,"nome"]=="Índice geral")){
        numero_ini <- numero_ini+1
        lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                  "Índice Nacional de Preços ao Cons. Amplo (IPCA)",
                                                                  "Índice Nacional de Preços ao Consumidor Amplo (IPCA)",
                                                                  "O IPCA tem por objetivo medir a inflação de um conjunto de produtos e serviços comercializados no varejo, referentes ao consumo pessoal das famílias. Atualmente, a população-objetivo do IPCA abrange as famílias com rendimentos de 1 a 40 salários mínimos, qualquer que seja a fonte, residentes nas regiões metropolitanas de Belém, Fortaleza, Recife, Salvador, Belo Horizonte, Vitória, Rio de Janeiro, São Paulo, Curitiba, Porto Alegre, além do Distrito Federal e dos municípios de Goiânia, Campo Grande, Rio Branco, São Luís e Aracaju.",
                                                                  "%",
                                                                  "IBGE",
                                                                  paste0("https://servicodados.ibge.gov.br/api/v3/agregados/7060/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=315[",categorias[w,"id"],"]"),
                                                                  1,
                                                                  "mensal",
                                                                  variaveis[i,"nome"],
                                                                  localidades[j,"nome_nivel"],
                                                                  localidades[j,"nome_loc"],
                                                                  categorias[w,"nome"])
      }
    }
  }
}
# transformar em data.frame
teste2 <- do.call("rbind",lista_dados)
teste2 <- as.data.frame(teste2)
# apagar o numero das linhas
row.names(teste2) <- NULL
# exportar como csv
write.csv(teste2, file="C:/Users/Kleber/Documents/ipca.csv", row.names = F)
#_______________________________________________________________________________________________________________________
# carregar os dados do IPCA-15 ----
#_______________________________________________________________________________________________________________________
# metadados do INPC
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/7062/metadados"
# carregar todos os metadados
ipca15 <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- ipca15$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- ipca15$variaveis
# remover o termo INPC das variaveis
variaveis$nome <- gsub("IPCA15 - ","", variaveis$nome)
variaveis <- variaveis[!variaveis$id%in%c(357),]
# filtrar as categorias
categorias <- ipca15$classificacoes$categorias[[1]]
categorias <- categorias[categorias$id%in%c(7169,7170,7445,7486,7558,7625,7660,7712,7766,7786),]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/7062/localidades/N7%7CN6%7CN1"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar coluna com os estados
localidades$estados <- c("(PA)","(CE)","(PE)","(BA)","(MG)","(RJ)","(SP)","(PR)","(RS)","(GO)","(DF)","")
# unir as cidades e estados
localidades$nome_loc <- paste(localidades$nome_loc, localidades$estados, sep=" ")
# remover o espaco no nome das localidades
localidades[localidades$id_loc==1,"nome_loc"] <- gsub(" ","",localidades[localidades$id_loc==1,"nome_loc"])
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar variavel com o ultimo numero de serie inserido manualmente no app
numero_ini <- 101023
# criar lista vazia para armazenar as series
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      if(!(localidades[j,"nome_loc"]=="Brasil"&categorias[w,"nome"]=="Índice geral")){
        numero_ini <- numero_ini+1
        lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                  "Índice Nac. de Preços ao Cons. Amplo 15 (IPCA-15)",
                                                                  "Índice Nacional de Preços ao Consumidor Amplo 15 (IPCA-15)",
                                                                  "O IPCA-15 difere do IPCA apenas no período de coleta que abrange, em geral, do dia 16 do mês anterior ao 15 do mês de referência e na abrangência geográfica. Atualmente, a população-objetivo do IPCA-15 abrange as famílias com rendimentos de 1 a 40 salários mínimos, qualquer que seja a fonte, residentes nas regiões metropolitanas de Belém, Fortaleza, Recife, Salvador, Belo Horizonte, Rio de Janeiro, São Paulo, Curitiba, Porto Alegre, além do Distrito Federal e do município de Goiânia.",
                                                                  "%",
                                                                  "IBGE",
                                                                  paste0("https://servicodados.ibge.gov.br/api/v3/agregados/7062/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=315[",categorias[w,"id"],"]"),
                                                                  1,
                                                                  "mensal",
                                                                  variaveis[i,"nome"],
                                                                  localidades[j,"nome_nivel"],
                                                                  localidades[j,"nome_loc"],
                                                                  categorias[w,"nome"])
      }
    }
  }
}
# transformar em data.frame
teste2 <- do.call("rbind",lista_dados)
teste2 <- as.data.frame(teste2)
# apagar o numero das linhas
row.names(teste2) <- NULL
# exportar como csv
write.csv(teste2, file="C:/Users/Kleber/Documents/ipca15.csv", row.names = F)
#_______________________________________________________________________________________________________________________
# carregar os dados do Indice de Precos ao Produtor - agregado 6723 ----
#_______________________________________________________________________________________________________________________
# metadados do INPC
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/6723/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# remover o termo INPC das variaveis
variaveis$nome <- gsub("IPP - ","", variaveis$nome)
variaveis <- variaveis[!variaveis$id%in%c(10008),]
variaveis[variaveis$id==1396,"nome"] <- "Variação mensal"
variaveis[variaveis$id==1395,"nome"] <- "Variação acumulada no ano"
variaveis[variaveis$id==1394,"nome"] <- "Variação acumulada em 12 anos"
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/6723/localidades/N1"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar variavel com o ultimo numero de serie inserido manualmente no app
numero_ini <- 101385
# criar lista vazia para armazenar as series
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      numero_ini <- numero_ini+1
        lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                  "Índice de Preços ao Produtor (IPP)",
                                                                  "Índice de Preços ao Produtor (IPP)",
                                                                  "O Índice de Preços ao Produtor - IPP, cujo âmbito são as indústrias extrativas e de transformação, tem como principal objetivo mensurar a mudança média dos preços de venda recebidos pelos produtores domésticos de bens e serviços, bem como sua evolução ao longo do tempo, sinalizando as tendências inflacionárias de curto prazo no País.O IPP investiga, em pouco mais de 2 100 empresas, os preços recebidos pelo produtor, isentos de impostos, tarifas e fretes e definidos segundo as práticas comerciais mais usuais. Os produtos coletados são especificados em detalhes (aspectos físicos e de transação), garantindo, dessa forma, que sejam comparados produtos homogêneos ao longo do tempo. Com isso, coletam-se cerca de 6 000 preços mensalmente.",
                                                                  "%",
                                                                  "IBGE",
                                                                  paste0("https://servicodados.ibge.gov.br/api/v3/agregados/6723/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=844[",categorias[w,"id"],"]"),
                                                                  1,
                                                                  "mensal",
                                                                  variaveis[i,"nome"],
                                                                  localidades[j,"nome_nivel"],
                                                                  localidades[j,"nome_loc"],
                                                                  categorias[w,"nome"])
    }
  }
}
# transformar em data.frame
teste2 <- do.call("rbind",lista_dados)
teste2 <- as.data.frame(teste2)
# apagar o numero das linhas
row.names(teste2) <- NULL
# exportar como csv
write.csv(teste2, file="C:/Users/Kleber/Documents/ipp6723.csv", row.names = F)
#_______________________________________________________________________________________________________________________
# carregar os dados do Indice de Precos ao Produtor - agregado 6903 ----
#_______________________________________________________________________________________________________________________
# metadados do INPC
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/6903/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# remover o termo INPC das variaveis
variaveis$nome <- gsub("IPP - ","", variaveis$nome)
variaveis <- variaveis[!variaveis$id%in%c(10008),]
variaveis[variaveis$id==1396,"nome"] <- "Variação mensal"
variaveis[variaveis$id==1395,"nome"] <- "Variação acumulada no ano"
variaveis[variaveis$id==1394,"nome"] <- "Variação acumulada em 12 anos"
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/6903/localidades/N1"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar variavel com o ultimo numero de serie inserido manualmente no app
numero_ini <- 101454
# criar lista vazia para armazenar as series
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      numero_ini <- numero_ini+1
      lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                "Índice de Preços ao Produtor (IPP)",
                                                                "Índice de Preços ao Produtor (IPP)",
                                                                "O Índice de Preços ao Produtor - IPP, cujo âmbito são as indústrias extrativas e de transformação, tem como principal objetivo mensurar a mudança média dos preços de venda recebidos pelos produtores domésticos de bens e serviços, bem como sua evolução ao longo do tempo, sinalizando as tendências inflacionárias de curto prazo no País.O IPP investiga, em pouco mais de 2 100 empresas, os preços recebidos pelo produtor, isentos de impostos, tarifas e fretes e definidos segundo as práticas comerciais mais usuais. Os produtos coletados são especificados em detalhes (aspectos físicos e de transação), garantindo, dessa forma, que sejam comparados produtos homogêneos ao longo do tempo. Com isso, coletam-se cerca de 6 000 preços mensalmente.",
                                                                "%",
                                                                "IBGE",
                                                                paste0("https://servicodados.ibge.gov.br/api/v3/agregados/6903/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=842[",categorias[w,"id"],"]"),
                                                                1,
                                                                "mensal",
                                                                variaveis[i,"nome"],
                                                                localidades[j,"nome_nivel"],
                                                                localidades[j,"nome_loc"],
                                                                tolower(categorias[w,"nome"]))
    }
  }
}
# transformar em data.frame
teste2 <- do.call("rbind",lista_dados)
teste2 <- as.data.frame(teste2)
# apagar o numero das linhas
row.names(teste2) <- NULL
# exportar como csv
write.csv(teste2, file="C:/Users/Kleber/Documents/ipp6903.csv", row.names = F)
#_______________________________________________________________________________________________________________________
# carregar os dados do Indice de Precos ao Produtor - agregado 6904 ----
#_______________________________________________________________________________________________________________________
# metadados do INPC
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/6904/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# remover o termo INPC das variaveis
variaveis$nome <- gsub("IPP - ","", variaveis$nome)
variaveis <- variaveis[!variaveis$id%in%c(10008),]
variaveis[variaveis$id==1396,"nome"] <- "Variação mensal"
variaveis[variaveis$id==1395,"nome"] <- "Variação acumulada no ano"
variaveis[variaveis$id==1394,"nome"] <- "Variação acumulada em 12 anos"
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/6904/localidades/N1"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar variavel com o ultimo numero de serie inserido manualmente no app
numero_ini <- 101532
# criar lista vazia para armazenar as series
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      numero_ini <- numero_ini+1
      lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                "Índice de Preços ao Produtor (IPP)",
                                                                "Índice de Preços ao Produtor (IPP)",
                                                                "O Índice de Preços ao Produtor - IPP, cujo âmbito são as indústrias extrativas e de transformação, tem como principal objetivo mensurar a mudança média dos preços de venda recebidos pelos produtores domésticos de bens e serviços, bem como sua evolução ao longo do tempo, sinalizando as tendências inflacionárias de curto prazo no País.O IPP investiga, em pouco mais de 2 100 empresas, os preços recebidos pelo produtor, isentos de impostos, tarifas e fretes e definidos segundo as práticas comerciais mais usuais. Os produtos coletados são especificados em detalhes (aspectos físicos e de transação), garantindo, dessa forma, que sejam comparados produtos homogêneos ao longo do tempo. Com isso, coletam-se cerca de 6 000 preços mensalmente.",
                                                                "%",
                                                                "IBGE",
                                                                paste0("https://servicodados.ibge.gov.br/api/v3/agregados/6904/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=543[",categorias[w,"id"],"]"),
                                                                1,
                                                                "mensal",
                                                                variaveis[i,"nome"],
                                                                localidades[j,"nome_nivel"],
                                                                localidades[j,"nome_loc"],
                                                                categorias[w,"nome"])
    }
  }
}
# transformar em data.frame
teste2 <- do.call("rbind",lista_dados)
teste2 <- as.data.frame(teste2)
# apagar o numero das linhas
row.names(teste2) <- NULL
# exportar como csv
write.csv(teste2, file="C:/Users/Kleber/Documents/ipp6904.csv", row.names = F)
#_______________________________________________________________________________________________________________________
# carregar os dados das Contas Nacionais Trimestrais - agregado 1620 ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/1620/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/1620/localidades/N1"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar variavel com o ultimo numero de serie inserido manualmente no app
numero_ini <- 199999
# criar lista vazia para armazenar as series
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      numero_ini <- numero_ini+1
      lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                "PIB trimestral observado",
                                                                "PIB trimestral observado (Base: média 1995 = 100)",
                                                                "Número-índice de volume com base de comparação em 1990; calculado pelo encadeamento da série base móvel trimestral.",
                                                                "Número-índice",
                                                                "IBGE",
                                                                paste0("https://servicodados.ibge.gov.br/api/v3/agregados/1620/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=11255[",categorias[w,"id"],"]"),
                                                                2,
                                                                "trimestral",
                                                                variaveis[i,"nome"],
                                                                localidades[j,"nome_nivel"],
                                                                localidades[j,"nome_loc"],
                                                                categorias[w,"nome"])
    }
  }
}
# transformar em data.frame
scnt1620 <- do.call("rbind",lista_dados)
scnt1620 <- as.data.frame(scnt1620)
# apagar o numero das linhas
row.names(scnt1620) <- NULL
#_______________________________________________________________________________________________________________________
# carregar os dados das Contas Nacionais Trimestrais - agregado 1621 ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/1621/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/1621/localidades/N1"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar lista vazia para armazenar as series
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      numero_ini <- numero_ini+1
      lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                "PIB trimestral com ajuste sazonal",
                                                                "PIB trimestral com ajuste sazonal (Base: média 1995 = 100)",
                                                                "Número-índice com base de comparação em 1990, calculada por encadeamento da série anterior. O ajuste sazonal foi realizado apenas nas séries onde foi identificado um componente sazonal significante utilizando-se o método X-13 ARIMA.",
                                                                "Número-índice",
                                                                "IBGE",
                                                                paste0("https://servicodados.ibge.gov.br/api/v3/agregados/1621/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=11255[",categorias[w,"id"],"]"),
                                                                2,
                                                                "trimestral",
                                                                variaveis[i,"nome"],
                                                                localidades[j,"nome_nivel"],
                                                                localidades[j,"nome_loc"],
                                                                categorias[w,"nome"])
    }
  }
}
# transformar em data.frame
scnt1621 <- do.call("rbind",lista_dados)
scnt1621 <- as.data.frame(scnt1621)
# apagar o numero das linhas
row.names(scnt1621) <- NULL
#_______________________________________________________________________________________________________________________
# carregar os dados das Contas Nacionais Trimestrais - agregado 1846 ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/1846/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/1846/localidades/N1"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar lista vazia para armazenar as series
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      numero_ini <- numero_ini+1
      lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                "PIB a preços correntes",
                                                                "PIB a preços correntes",
                                                                "PIB a preços correntes da produção (R\\$ milhões).",
                                                                "R\\$ milhões",
                                                                "IBGE",
                                                                paste0("https://servicodados.ibge.gov.br/api/v3/agregados/1846/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=11255[",categorias[w,"id"],"]"),
                                                                2,
                                                                "trimestral",
                                                                variaveis[i,"nome"],
                                                                localidades[j,"nome_nivel"],
                                                                localidades[j,"nome_loc"],
                                                                categorias[w,"nome"])
    }
  }
}
# transformar em data.frame
scnt1846 <- do.call("rbind",lista_dados)
scnt1846 <- as.data.frame(scnt1846)
# apagar o numero das linhas
row.names(scnt1846) <- NULL
#_______________________________________________________________________________________________________________________
# carregar os dados das Contas Nacionais Trimestrais - agregado 2072 ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/2072/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/2072/localidades/N1"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar lista vazia para armazenar as series
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
      numero_ini <- numero_ini+1
      lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                "Contas econômicas trimestrais",
                                                                "Contas econômicas trimestrais",
                                                                "Valor das Contas econômicas trimestrais (R\\$ milhões).",
                                                                "R\\$ milhões",
                                                                "IBGE",
                                                                paste0("https://servicodados.ibge.gov.br/api/v3/agregados/2072/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]"),
                                                                2,
                                                                "trimestral",
                                                                variaveis[i,"nome"],
                                                                localidades[j,"nome_nivel"],
                                                                localidades[j,"nome_loc"],
                                                                categorias[w,"nome"])
  }
}
# transformar em data.frame
scnt2072 <- do.call("rbind",lista_dados)
scnt2072 <- as.data.frame(scnt2072)
# apagar o numero das linhas
row.names(scnt2072) <- NULL
#_______________________________________________________________________________________________________________________
# carregar os dados das Contas Nacionais Trimestrais - agregado 2205 ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/2205/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/2205/localidades/N1"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar lista vazia para armazenar as series
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      numero_ini <- numero_ini+1
      lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                "Conta financeira trimestral consolidada",
                                                                "Conta financeira trimestral consolidada",
                                                                "Valor da conta financeira trimestral consolidada (R\\$ milhões)",
                                                                "R\\$ milhões",
                                                                "IBGE",
                                                                paste0("https://servicodados.ibge.gov.br/api/v3/agregados/2205/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=12116[",categorias[w,"id"],"]"),
                                                                2,
                                                                "trimestral",
                                                                variaveis[i,"nome"],
                                                                localidades[j,"nome_nivel"],
                                                                localidades[j,"nome_loc"],
                                                                categorias[w,"nome"])
    }
  }
}
# transformar em data.frame
scnt2205 <- do.call("rbind",lista_dados)
scnt2205 <- as.data.frame(scnt2205)
# apagar o numero das linhas
row.names(scnt2205) <- NULL
#_______________________________________________________________________________________________________________________
# carregar os dados das Contas Nacionais Trimestrais - agregado 5932 ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/5932/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/5932/localidades/N1"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar lista vazia para armazenar as series
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      numero_ini <- numero_ini+1
      lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                "Taxa de variação do PIB trimestral",
                                                                "Taxa de variação do PIB trimestral",
                                                                "Representa a taxa de variação do índice de volume trimestral do PIB.",
                                                                "%",
                                                                "IBGE",
                                                                paste0("https://servicodados.ibge.gov.br/api/v3/agregados/5932/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=11255[",categorias[w,"id"],"]"),
                                                                2,
                                                                "trimestral",
                                                                variaveis[i,"nome"],
                                                                localidades[j,"nome_nivel"],
                                                                localidades[j,"nome_loc"],
                                                                categorias[w,"nome"])
    }
  }
}
# transformar em data.frame
scnt5932 <- do.call("rbind",lista_dados)
scnt5932 <- as.data.frame(scnt5932)
# apagar o numero das linhas
row.names(scnt5932) <- NULL
#_______________________________________________________________________________________________________________________
# carregar os dados das Contas Nacionais Trimestrais - agregado 6612 ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/6612/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/6612/localidades/N1"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar lista vazia para armazenar as series
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      numero_ini <- numero_ini+1
      lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                "PIB - valores encadeados a preços de 1995",
                                                                "PIB - valores encadeados a preços de 1995",
                                                                "PIB calculado pelo encadeamento da série base móvel trimestral.",
                                                                "R\\$ milhões",
                                                                "IBGE",
                                                                paste0("https://servicodados.ibge.gov.br/api/v3/agregados/6612/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=11255[",categorias[w,"id"],"]"),
                                                                2,
                                                                "trimestral",
                                                                variaveis[i,"nome"],
                                                                localidades[j,"nome_nivel"],
                                                                localidades[j,"nome_loc"],
                                                                categorias[w,"nome"])
    }
  }
}
# transformar em data.frame
scnt6612 <- do.call("rbind",lista_dados)
scnt6612 <- as.data.frame(scnt6612)
# apagar o numero das linhas
row.names(scnt6612) <- NULL
#_______________________________________________________________________________________________________________________
# carregar os dados das Contas Nacionais Trimestrais - agregado 6613 ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/6613/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/6613/localidades/N1"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar lista vazia para armazenar as series
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      numero_ini <- numero_ini+1
      lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                "PIB - valores encadeados a preços de 1995 com ajuste sazonal",
                                                                "PIB - valores encadeados a preços de 1995 com ajuste sazonal",
                                                                "PIB calculado pelos valores encadeados a preços de 1995. O ajuste sazonal foi realizado apenas nas séries onde foi identificado um componente sazonal significante utilizando-se o método X-13 ARIMA.",
                                                                "R\\$ milhões",
                                                                "IBGE",
                                                                paste0("https://servicodados.ibge.gov.br/api/v3/agregados/6613/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=11255[",categorias[w,"id"],"]"),
                                                                2,
                                                                "trimestral",
                                                                variaveis[i,"nome"],
                                                                localidades[j,"nome_nivel"],
                                                                localidades[j,"nome_loc"],
                                                                categorias[w,"nome"])
    }
  }
}
# transformar em data.frame
scnt6613 <- do.call("rbind",lista_dados)
scnt6613 <- as.data.frame(scnt6613)
# apagar o numero das linhas
row.names(scnt6613) <- NULL
#_______________________________________________________________________________________________________________________
# carregar os dados das Contas Nacionais Trimestrais - agregado 6726 ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/6726/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/6726/localidades/N1"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar lista vazia para armazenar as series
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
      numero_ini <- numero_ini+1
      lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                "Taxa de poupança",
                                                                "Taxa de poupança",
                                                                "Representa o montante que deixa de ser consumido pela população e acaba sendo usada para investimento.",
                                                                "% do PIB",
                                                                "IBGE",
                                                                paste0("https://servicodados.ibge.gov.br/api/v3/agregados/6726/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]"),
                                                                2,
                                                                "trimestral",
                                                                variaveis[i,"nome"],
                                                                localidades[j,"nome_nivel"],
                                                                localidades[j,"nome_loc"],
                                                                "Valor geral")

  }
}
# transformar em data.frame
scnt6726 <- do.call("rbind",lista_dados)
scnt6726 <- as.data.frame(scnt6726)
# apagar o numero das linhas
row.names(scnt6726) <- NULL
#_______________________________________________________________________________________________________________________
# carregar os dados das Contas Nacionais Trimestrais - agregado 6727 ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/6727/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/6727/localidades/N1"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar lista vazia para armazenar as series
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
      numero_ini <- numero_ini+1
      lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                "Taxa de investimento",
                                                                "Taxa de investimento",
                                                                "Representa o montante destinado ao investimento.",
                                                                "% do PIB",
                                                                "IBGE",
                                                                paste0("https://servicodados.ibge.gov.br/api/v3/agregados/6727/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]"),
                                                                2,
                                                                "trimestral",
                                                                variaveis[i,"nome"],
                                                                localidades[j,"nome_nivel"],
                                                                localidades[j,"nome_loc"],
                                                                "Valor geral")
  }
}
# transformar em data.frame
scnt6727 <- do.call("rbind",lista_dados)
scnt6727 <- as.data.frame(scnt6727)
# apagar o numero das linhas
row.names(scnt6727) <- NULL
# unir as tabelas
scnt_total <- bind_rows(scnt1620, scnt1621, scnt1846, scnt2072, scnt2205, scnt5932, scnt6612, scnt6613, scnt6726,
                        scnt6727)

# exportar como csv
write.csv(scnt_total, file="C:/Users/Kleber/Documents/scnt_total.csv", row.names = F)
#_______________________________________________________________________________________________________________________
# carregar os dados da Pesquisa Industrial Mensal - Producao Fisica (agregado 8885) ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/8885/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# ajustar o nome das variaveis
variaveis$nome <- gsub("PIMPF - ","",variaveis$nome)
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/8885/localidades/N1"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar variavel com o ultimo numero de serie inserido manualmente no app
numero_ini <- 200265
# criar lista vazia
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      numero_ini <- numero_ini+1
      lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                "Pesquisa Industrial Mensal - Produção Física",
                                                                "Pesquisa Industrial Mensal - Produção Física",
                                                                "Produz indicadores de curto prazo relativos ao comportamento do produto real da indústria, tendo como unidade de investigação a empresa formalmente constituída cuja principal fonte de receita seja a atividade industrial.",
                                                                "%",
                                                                "IBGE",
                                                                paste0("https://servicodados.ibge.gov.br/api/v3/agregados/8885/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=542[",categorias[w,"id"],"]"),
                                                                2,
                                                                "mensal",
                                                                variaveis[i,"nome"],
                                                                localidades[j,"nome_nivel"],
                                                                localidades[j,"nome_loc"],
                                                                categorias[w,"nome"])
    }
  }
}
# transformar em data.frame
pimpf <- do.call("rbind",lista_dados)
pimpf <- as.data.frame(pimpf)
# apagar o numero das linhas
row.names(pimpf) <- NULL
# exportar como csv
write.csv(pimpf, file="C:/Users/Kleber/Documents/pimpf8885.csv", row.names = F)
#_______________________________________________________________________________________________________________________
# carregar os dados da Pesquisa Industrial Mensal - Producao Fisica (agregado 8886) ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/8886/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# ajustar o nome das variaveis
variaveis$nome <- gsub("PIMPF - ","",variaveis$nome)
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/8886/localidades/N1"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar variavel com o ultimo numero de serie inserido manualmente no app
numero_ini <- 200685
# criar lista vazia
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
      numero_ini <- numero_ini+1
      lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                "Pesquisa Industrial Mensal - Produção Física",
                                                                "Pesquisa Industrial Mensal - Produção Física",
                                                                "Produz indicadores de curto prazo relativos ao comportamento do produto real da indústria, tendo como unidade de investigação a empresa formalmente constituída cuja principal fonte de receita seja a atividade industrial.",
                                                                "%",
                                                                "IBGE",
                                                                paste0("https://servicodados.ibge.gov.br/api/v3/agregados/8886/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]"),
                                                                2,
                                                                "mensal",
                                                                variaveis[i,"nome"],
                                                                localidades[j,"nome_nivel"],
                                                                localidades[j,"nome_loc"],
                                                                "Índice geral")
  }
}
# transformar em data.frame
pimpf <- do.call("rbind",lista_dados)
pimpf <- as.data.frame(pimpf)
# apagar o numero das linhas
row.names(pimpf) <- NULL
# exportar como csv
write.csv(pimpf, file="C:/Users/Kleber/Documents/pimpf8886.csv", row.names = F)
#_______________________________________________________________________________________________________________________
# carregar os dados da Pesquisa Industrial Mensal - Producao Fisica (agregado 8887) ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/8887/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# ajustar o nome das variaveis
variaveis$nome <- gsub("PIMPF - ","",variaveis$nome)
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/8887/localidades/N1"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar variavel com o ultimo numero de serie inserido manualmente no app
numero_ini <- 200689
# criar lista vazia
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      numero_ini <- numero_ini+1
      lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                "Pesquisa Industrial Mensal - Produção Física",
                                                                "Pesquisa Industrial Mensal - Produção Física",
                                                                "Produz indicadores de curto prazo relativos ao comportamento do produto real da indústria, tendo como unidade de investigação a empresa formalmente constituída cuja principal fonte de receita seja a atividade industrial.",
                                                                "%",
                                                                "IBGE",
                                                                paste0("https://servicodados.ibge.gov.br/api/v3/agregados/8887/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=543[",categorias[w,"id"],"]"),
                                                                2,
                                                                "mensal",
                                                                variaveis[i,"nome"],
                                                                localidades[j,"nome_nivel"],
                                                                localidades[j,"nome_loc"],
                                                                categorias[w,"nome"])
    }
  }
}
# transformar em data.frame
pimpf <- do.call("rbind",lista_dados)
pimpf <- as.data.frame(pimpf)
# apagar o numero das linhas
row.names(pimpf) <- NULL
# exportar como csv
write.csv(pimpf, file="C:/Users/Kleber/Documents/pimpf8887.csv", row.names = F)
#_______________________________________________________________________________________________________________________
# carregar os dados da Pesquisa Industrial Mensal - Producao Fisica (agregado 8888) ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/8888/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# ajustar o nome das variaveis
variaveis$nome <- gsub("PIMPF - ","",variaveis$nome)
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/8888/localidades/N1|N2|N3"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar variavel com o ultimo numero de serie inserido manualmente no app
numero_ini <- 200833
# criar lista vazia
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      numero_ini <- numero_ini+1
      if(i%in%grep("índice",variaveis$nome)){
        unidade <- variaveis[i,"nome"]
      } else {
        unidade <- "%"
      }
      lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                "Pesquisa Industrial Mensal - Produção Física",
                                                                "Pesquisa Industrial Mensal - Produção Física",
                                                                "Produz indicadores de curto prazo relativos ao comportamento do produto real da indústria, tendo como unidade de investigação a empresa formalmente constituída cuja principal fonte de receita seja a atividade industrial.",
                                                                unidade,
                                                                "IBGE",
                                                                paste0("https://servicodados.ibge.gov.br/api/v3/agregados/8888/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=544[",categorias[w,"id"],"]"),
                                                                2,
                                                                "mensal",
                                                                variaveis[i,"nome"],
                                                                localidades[j,"nome_nivel"],
                                                                localidades[j,"nome_loc"],
                                                                categorias[w,"nome"])
    }
  }
}
# transformar em data.frame
pimpf <- do.call("rbind",lista_dados)
pimpf <- as.data.frame(pimpf)
# apagar o numero das linhas
row.names(pimpf) <- NULL
# exportar como csv
write.csv(pimpf, file="C:/Users/Kleber/Documents/pimpf8888.csv", row.names = F)
#_______________________________________________________________________________________________________________________
# carregar os dados da Pesquisa Industrial Mensal - Producao Fisica  (agregado 8889) ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/8889/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# ajustar o nome das variaveis
variaveis$nome <- gsub("PIMPF - ","",variaveis$nome)
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/8889/localidades/N1"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar variavel com o ultimo numero de serie inserido manualmente no app
numero_ini <- 203911
# criar lista vazia
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      numero_ini <- numero_ini+1
      if(i%in%grep("índice",variaveis$nome)){
        unidade <- variaveis[i,"nome"]
      } else {
        unidade <- "%"
      }
      lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                "Pesquisa Industrial Mensal - Produção Física",
                                                                "Pesquisa Industrial Mensal - Produção Física",
                                                                "Produz indicadores de curto prazo relativos ao comportamento do produto real da indústria, tendo como unidade de investigação a empresa formalmente constituída cuja principal fonte de receita seja a atividade industrial.",
                                                                unidade,
                                                                "IBGE",
                                                                paste0("https://servicodados.ibge.gov.br/api/v3/agregados/8889/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=25[",categorias[w,"id"],"]"),
                                                                2,
                                                                "mensal",
                                                                variaveis[i,"nome"],
                                                                localidades[j,"nome_nivel"],
                                                                localidades[j,"nome_loc"],
                                                                categorias[w,"nome"])
    }
  }
}
# transformar em data.frame
pimpf <- do.call("rbind",lista_dados)
pimpf <- as.data.frame(pimpf)
# apagar o numero das linhas
row.names(pimpf) <- NULL
# exportar como csv
write.csv(pimpf, file="C:/Users/Kleber/Documents/pimpf8889.csv", row.names = F)
#_______________________________________________________________________________________________________________________
# carregar os dados da Pesquisa Mensal de Comercio  (agregado 8190) ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/8190/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# ajustar o nome das variaveis
variaveis$nome <- gsub("PIMPF - ","",variaveis$nome)
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/8190/localidades/N1|N3"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar variavel com o ultimo numero de serie inserido manualmente no app
numero_ini <- 204187
# criar lista vazia
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      numero_ini <- numero_ini+1
      if(i%in%grep("índice",variaveis$nome)){
        unidade <- variaveis[i,"nome"]
      } else {
        unidade <- "%"
      }
      lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                "Pesquisa Mensal de Comércio",
                                                                "Pesquisa Mensal de Comércio",
                                                                "A Pesquisa Mensal de Comércio produz indicadores que permitem acompanhar o comportamento conjuntural do comércio varejista no País, investigando a receita bruta de revenda nas empresas formalmente constituídas, com 20 ou mais pessoas ocupadas, e cuja atividade principal é o comércio varejista.",
                                                                unidade,
                                                                "IBGE",
                                                                paste0("https://servicodados.ibge.gov.br/api/v3/agregados/8190/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=11046[",categorias[w,"id"],"]"),
                                                                2,
                                                                "mensal",
                                                                variaveis[i,"nome"],
                                                                localidades[j,"nome_nivel"],
                                                                localidades[j,"nome_loc"],
                                                                categorias[w,"nome"])
    }
  }
}
# transformar em data.frame
pimpf <- do.call("rbind",lista_dados)
pimpf <- as.data.frame(pimpf)
# apagar o numero das linhas
row.names(pimpf) <- NULL
# exportar como csv
write.csv(pimpf, file="C:/Users/Kleber/Documents/pmc8190.csv", row.names = F)
#_______________________________________________________________________________________________________________________
# carregar os dados da Pesquisa Mensal de Comercio  (agregado 8757) ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/8757/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# ajustar o nome das variaveis
variaveis$nome <- gsub("PMC - ","",variaveis$nome)
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/8757/localidades/N1|N3"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar variavel com o ultimo numero de serie inserido manualmente no app
numero_ini <- 204265
# criar lista vazia
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      numero_ini <- numero_ini+1
      if(i%in%grep("índice",variaveis$nome)){
        unidade <- variaveis[i,"nome"]
      } else {
        unidade <- "%"
      }
      lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                "Pesquisa Mensal de Comércio",
                                                                "Pesquisa Mensal de Comércio",
                                                                "A Pesquisa Mensal de Comércio produz indicadores que permitem acompanhar o comportamento conjuntural do comércio varejista no País, investigando a receita bruta de revenda nas empresas formalmente constituídas, com 20 ou mais pessoas ocupadas, e cuja atividade principal é o comércio varejista.",
                                                                unidade,
                                                                "IBGE",
                                                                paste0("https://servicodados.ibge.gov.br/api/v3/agregados/8757/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=11046[",categorias[w,"id"],"]"),
                                                                2,
                                                                "mensal",
                                                                variaveis[i,"nome"],
                                                                localidades[j,"nome_nivel"],
                                                                localidades[j,"nome_loc"],
                                                                categorias[w,"nome"])
    }
  }
}
# transformar em data.frame
pimpf <- do.call("rbind",lista_dados)
pimpf <- as.data.frame(pimpf)
# apagar o numero das linhas
row.names(pimpf) <- NULL
# exportar como csv
write.csv(pimpf, file="C:/Users/Kleber/Documents/pmc8757.csv", row.names = F)
#_______________________________________________________________________________________________________________________
# carregar os dados da Pesquisa Mensal de Comercio  (agregado 8880) ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/8880/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# ajustar o nome das variaveis
variaveis$nome <- gsub("PMC - ","",variaveis$nome)
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/8880/localidades/N1|N3"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar variavel com o ultimo numero de serie inserido manualmente no app
numero_ini <- 204421
# criar lista vazia
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      numero_ini <- numero_ini+1
      if(i%in%grep("índice",variaveis$nome)){
        unidade <- variaveis[i,"nome"]
      } else {
        unidade <- "%"
      }
      lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                "Pesquisa Mensal de Comércio",
                                                                "Pesquisa Mensal de Comércio",
                                                                "A Pesquisa Mensal de Comércio produz indicadores que permitem acompanhar o comportamento conjuntural do comércio varejista no País, investigando a receita bruta de revenda nas empresas formalmente constituídas, com 20 ou mais pessoas ocupadas, e cuja atividade principal é o comércio varejista.",
                                                                unidade,
                                                                "IBGE",
                                                                paste0("https://servicodados.ibge.gov.br/api/v3/agregados/8880/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=11046[",categorias[w,"id"],"]"),
                                                                2,
                                                                "mensal",
                                                                variaveis[i,"nome"],
                                                                localidades[j,"nome_nivel"],
                                                                localidades[j,"nome_loc"],
                                                                categorias[w,"nome"])
    }
  }
}
# transformar em data.frame
pimpf <- do.call("rbind",lista_dados)
pimpf <- as.data.frame(pimpf)
# apagar o numero das linhas
row.names(pimpf) <- NULL
# exportar como csv
write.csv(pimpf, file="C:/Users/Kleber/Documents/pmc8880.csv", row.names = F)
#_______________________________________________________________________________________________________________________
# carregar os dados da Pesquisa Mensal de Comercio  (agregado 8881) ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/8881/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# ajustar o nome das variaveis
variaveis$nome <- gsub("PMC - ","",variaveis$nome)
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/8881/localidades/N1|N3"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar variavel com o ultimo numero de serie inserido manualmente no app
numero_ini <- 204757
# criar lista vazia
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      numero_ini <- numero_ini+1
      if(i%in%grep("índice",variaveis$nome)){
        unidade <- variaveis[i,"nome"]
      } else {
        unidade <- "%"
      }
      lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                "Pesquisa Mensal de Comércio",
                                                                "Pesquisa Mensal de Comércio",
                                                                "A Pesquisa Mensal de Comércio produz indicadores que permitem acompanhar o comportamento conjuntural do comércio varejista no País, investigando a receita bruta de revenda nas empresas formalmente constituídas, com 20 ou mais pessoas ocupadas, e cuja atividade principal é o comércio varejista.",
                                                                unidade,
                                                                "IBGE",
                                                                paste0("https://servicodados.ibge.gov.br/api/v3/agregados/8881/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=11046[",categorias[w,"id"],"]"),
                                                                2,
                                                                "mensal",
                                                                variaveis[i,"nome"],
                                                                localidades[j,"nome_nivel"],
                                                                localidades[j,"nome_loc"],
                                                                categorias[w,"nome"])
    }
  }
}
# transformar em data.frame
pimpf <- do.call("rbind",lista_dados)
pimpf <- as.data.frame(pimpf)
# apagar o numero das linhas
row.names(pimpf) <- NULL
# exportar como csv
write.csv(pimpf, file="C:/Users/Kleber/Documents/pmc8881.csv", row.names = F)
#_______________________________________________________________________________________________________________________
# carregar os dados da Pesquisa Mensal de Comercio  (agregado 8881) ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/8881/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# ajustar o nome das variaveis
variaveis$nome <- gsub("PMC - ","",variaveis$nome)
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/8881/localidades/N1|N3"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar variavel com o ultimo numero de serie inserido manualmente no app
numero_ini <- 204757
# criar lista vazia
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      numero_ini <- numero_ini+1
      if(i%in%grep("índice",variaveis$nome)){
        unidade <- variaveis[i,"nome"]
      } else {
        unidade <- "%"
      }
      lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                "Pesquisa Mensal de Comércio",
                                                                "Pesquisa Mensal de Comércio",
                                                                "A Pesquisa Mensal de Comércio produz indicadores que permitem acompanhar o comportamento conjuntural do comércio varejista no País, investigando a receita bruta de revenda nas empresas formalmente constituídas, com 20 ou mais pessoas ocupadas, e cuja atividade principal é o comércio varejista.",
                                                                unidade,
                                                                "IBGE",
                                                                paste0("https://servicodados.ibge.gov.br/api/v3/agregados/8881/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=11046[",categorias[w,"id"],"]"),
                                                                2,
                                                                "mensal",
                                                                variaveis[i,"nome"],
                                                                localidades[j,"nome_nivel"],
                                                                localidades[j,"nome_loc"],
                                                                categorias[w,"nome"])
    }
  }
}
# transformar em data.frame
pimpf <- do.call("rbind",lista_dados)
pimpf <- as.data.frame(pimpf)
# apagar o numero das linhas
row.names(pimpf) <- NULL
# exportar como csv
write.csv(pimpf, file="C:/Users/Kleber/Documents/pmc8881.csv", row.names = F)
#_______________________________________________________________________________________________________________________
# carregar os dados da Pesquisa Mensal de Comercio  (agregado 8882) ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/8882/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# ajustar o nome das variaveis
variaveis$nome <- gsub("PMC - ","",variaveis$nome)
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# filtrar as atividades
atividades <- serie$classificacoes$categorias[[2]]

# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/8882/localidades/N1|N3"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar variavel com o ultimo numero de serie inserido manualmente no app
numero_ini <- 205093
# criar lista vazia
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      for(k in 1:nrow(atividades)){
        numero_ini <- numero_ini+1
        if(i%in%grep("índice",variaveis$nome)){
          unidade <- variaveis[i,"nome"]
        } else {
          unidade <- "%"
        }
        lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                  "Pesquisa Mensal de Comércio",
                                                                  "Pesquisa Mensal de Comércio",
                                                                  "A Pesquisa Mensal de Comércio produz indicadores que permitem acompanhar o comportamento conjuntural do comércio varejista no País, investigando a receita bruta de revenda nas empresas formalmente constituídas, com 20 ou mais pessoas ocupadas, e cuja atividade principal é o comércio varejista.",
                                                                  unidade,
                                                                  "IBGE",
                                                                  paste0("https://servicodados.ibge.gov.br/api/v3/agregados/8882/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=11046[",categorias[w,"id"],"]|85[",atividades[k,"id"],"]"),
                                                                  2,
                                                                  "mensal",
                                                                  variaveis[i,"nome"],
                                                                  localidades[j,"nome_nivel"],
                                                                  localidades[j,"nome_loc"],
                                                                  paste0(categorias[w,"nome"]," - ",atividades[k,"nome"]))
      }
    }
  }
}
# transformar em data.frame
pimpf <- do.call("rbind",lista_dados)
pimpf <- as.data.frame(pimpf)
# apagar o numero das linhas
row.names(pimpf) <- NULL
# exportar como csv
write.csv(pimpf, file="C:/Users/Kleber/Documents/pmc8882.csv", row.names = F)
#_______________________________________________________________________________________________________________________
# carregar os dados da Pesquisa Mensal de Comercio  (agregado 8883) ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/8883/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# ajustar o nome das variaveis
variaveis$nome <- gsub("PMC - ","",variaveis$nome)
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# filtrar as atividades
atividades <- serie$classificacoes$categorias[[2]]

# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/8883/localidades/N1|N3"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar variavel com o ultimo numero de serie inserido manualmente no app
numero_ini <- 206809
# criar lista vazia
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      for(k in 1:nrow(atividades)){
        numero_ini <- numero_ini+1
        if(i%in%grep("índice",variaveis$nome)){
          unidade <- variaveis[i,"nome"]
        } else {
          unidade <- "%"
        }
        lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                  "Pesquisa Mensal de Comércio",
                                                                  "Pesquisa Mensal de Comércio",
                                                                  "A Pesquisa Mensal de Comércio produz indicadores que permitem acompanhar o comportamento conjuntural do comércio varejista no País, investigando a receita bruta de revenda nas empresas formalmente constituídas, com 20 ou mais pessoas ocupadas, e cuja atividade principal é o comércio varejista.",
                                                                  unidade,
                                                                  "IBGE",
                                                                  paste0("https://servicodados.ibge.gov.br/api/v3/agregados/8883/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=11046[",categorias[w,"id"],"]|85[",atividades[k,"id"],"]"),
                                                                  2,
                                                                  "mensal",
                                                                  variaveis[i,"nome"],
                                                                  localidades[j,"nome_nivel"],
                                                                  localidades[j,"nome_loc"],
                                                                  paste0(categorias[w,"nome"]," - ",atividades[k,"nome"]))
      }
    }
  }
}
# transformar em data.frame
pimpf <- do.call("rbind",lista_dados)
pimpf <- as.data.frame(pimpf)
# apagar o numero das linhas
row.names(pimpf) <- NULL
# exportar como csv
write.csv(pimpf, file="C:/Users/Kleber/Documents/pmc8883.csv", row.names = F)
#_______________________________________________________________________________________________________________________
# carregar os dados da Pesquisa Mensal de Comercio  (agregado 8884) ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/8884/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# ajustar o nome das variaveis
variaveis$nome <- gsub("PMC - ","",variaveis$nome)
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/8884/localidades/N1|N3"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar variavel com o ultimo numero de serie inserido manualmente no app
numero_ini <- 208993
# criar lista vazia
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
        numero_ini <- numero_ini+1
        if(i%in%grep("índice",variaveis$nome)){
          unidade <- variaveis[i,"nome"]
        } else {
          unidade <- "%"
        }
        lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                  "Pesquisa Mensal de Comércio",
                                                                  "Pesquisa Mensal de Comércio",
                                                                  "A Pesquisa Mensal de Comércio produz indicadores que permitem acompanhar o comportamento conjuntural do comércio varejista no País, investigando a receita bruta de revenda nas empresas formalmente constituídas, com 20 ou mais pessoas ocupadas, e cuja atividade principal é o comércio varejista.",
                                                                  unidade,
                                                                  "IBGE",
                                                                  paste0("https://servicodados.ibge.gov.br/api/v3/agregados/8884/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=11046[",categorias[w,"id"],"]"),
                                                                  2,
                                                                  "mensal",
                                                                  variaveis[i,"nome"],
                                                                  localidades[j,"nome_nivel"],
                                                                  localidades[j,"nome_loc"],
                                                                  categorias[w,"nome"])
    }
  }
}
# transformar em data.frame
pimpf <- do.call("rbind",lista_dados)
pimpf <- as.data.frame(pimpf)
# apagar o numero das linhas
row.names(pimpf) <- NULL
# exportar como csv
write.csv(pimpf, file="C:/Users/Kleber/Documents/pmc8884.csv", row.names = F)
#_______________________________________________________________________________________________________________________
# carregar os dados da Pesquisa Mensal de Servicos  (agregado 5906) ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/5906/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# ajustar o nome das variaveis
variaveis$nome <- gsub("PMS - ","",variaveis$nome)
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/5906/localidades/N1|N3"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar variavel com o ultimo numero de serie inserido manualmente no app
numero_ini <- 209149
# criar lista vazia
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      numero_ini <- numero_ini+1
      if(i%in%grep("índice",variaveis$nome)){
        unidade <- variaveis[i,"nome"]
      } else {
        unidade <- "%"
      }
      lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                "Pesquisa Mensal de Serviços",
                                                                "Pesquisa Mensal de Serviços",
                                                                "A Pesquisa Mensal de Serviços produz indicadores que permitem acompanhar o comportamento conjuntural do setor de serviços no País, investigando a receita bruta de serviços nas empresas formalmente constituídas, com 20 ou mais pessoas ocupadas, que desempenham como principal atividade um serviço não financeiro, excluídas as áreas de saúde e educação.",
                                                                unidade,
                                                                "IBGE",
                                                                paste0("https://servicodados.ibge.gov.br/api/v3/agregados/5906/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=11046[",categorias[w,"id"],"]"),
                                                                2,
                                                                "mensal",
                                                                variaveis[i,"nome"],
                                                                localidades[j,"nome_nivel"],
                                                                localidades[j,"nome_loc"],
                                                                categorias[w,"nome"])
    }
  }
}
# transformar em data.frame
pimpf <- do.call("rbind",lista_dados)
pimpf <- as.data.frame(pimpf)
# apagar o numero das linhas
row.names(pimpf) <- NULL
# exportar como csv
write.csv(pimpf, file="C:/Users/Kleber/Documents/pms5906.csv", row.names = F)
#_______________________________________________________________________________________________________________________
# carregar os dados da Pesquisa Mensal de Servicos  (agregado 8163) ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/8163/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# ajustar o nome das variaveis
variaveis$nome <- gsub("PMS - ","",variaveis$nome)
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# filtrar as atividades
atividades <- serie$classificacoes$categorias[[2]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/8163/localidades/N1"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar variavel com o ultimo numero de serie inserido manualmente no app
numero_ini <- 209485
# criar lista vazia
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      for(k in 1:nrow(atividades)){
        numero_ini <- numero_ini+1
        if(i%in%grep("índice",variaveis$nome)){
          unidade <- variaveis[i,"nome"]
        } else {
          unidade <- "%"
        }
        lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                  "Pesquisa Mensal de Serviços",
                                                                  "Pesquisa Mensal de Serviços",
                                                                  "A Pesquisa Mensal de Serviços produz indicadores que permitem acompanhar o comportamento conjuntural do setor de serviços no País, investigando a receita bruta de serviços nas empresas formalmente constituídas, com 20 ou mais pessoas ocupadas, que desempenham como principal atividade um serviço não financeiro, excluídas as áreas de saúde e educação.",
                                                                  unidade,
                                                                  "IBGE",
                                                                  paste0("https://servicodados.ibge.gov.br/api/v3/agregados/8163/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=11046[",categorias[w,"id"],"]|1274[",atividades[k,"id"],"]"),
                                                                  2,
                                                                  "mensal",
                                                                  variaveis[i,"nome"],
                                                                  localidades[j,"nome_nivel"],
                                                                  localidades[j,"nome_loc"],
                                                                  paste0(categorias[w,"nome"], " - ", atividades[k,"nome"]))
      }
    }
  }
}
# transformar em data.frame
pimpf <- do.call("rbind",lista_dados)
pimpf <- as.data.frame(pimpf)
# apagar o numero das linhas
row.names(pimpf) <- NULL
# exportar como csv
write.csv(pimpf, file="C:/Users/Kleber/Documents/pms8163.csv", row.names = F)
#_______________________________________________________________________________________________________________________
# carregar os dados da Pesquisa Mensal de Servicos  (agregado 8694) ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/8694/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# ajustar o nome das variaveis
variaveis$nome <- gsub("PMS - ","",variaveis$nome)
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/8694/localidades/N1"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar variavel com o ultimo numero de serie inserido manualmente no app
numero_ini <- 209725
# criar lista vazia
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
        numero_ini <- numero_ini+1
        if(i%in%grep("índice",variaveis$nome)){
          unidade <- variaveis[i,"nome"]
        } else {
          unidade <- "%"
        }
        lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                  "Pesquisa Mensal de Serviços",
                                                                  "Pesquisa Mensal de Serviços",
                                                                  "A Pesquisa Mensal de Serviços produz indicadores que permitem acompanhar o comportamento conjuntural do setor de serviços no País, investigando a receita bruta de serviços nas empresas formalmente constituídas, com 20 ou mais pessoas ocupadas, que desempenham como principal atividade um serviço não financeiro, excluídas as áreas de saúde e educação.",
                                                                  unidade,
                                                                  "IBGE",
                                                                  paste0("https://servicodados.ibge.gov.br/api/v3/agregados/8694/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=11046[",categorias[w,"id"],"]"),
                                                                  2,
                                                                  "mensal",
                                                                  variaveis[i,"nome"],
                                                                  localidades[j,"nome_nivel"],
                                                                  localidades[j,"nome_loc"],
                                                                  categorias[w,"nome"])
    }
  }
}
# transformar em data.frame
pimpf <- do.call("rbind",lista_dados)
pimpf <- as.data.frame(pimpf)
# apagar o numero das linhas
row.names(pimpf) <- NULL
# exportar como csv
write.csv(pimpf, file="C:/Users/Kleber/Documents/pms8694.csv", row.names = F)
#_______________________________________________________________________________________________________________________
# carregar os dados da Pesquisa Mensal de Servicos  (agregado 8695) ----
#_______________________________________________________________________________________________________________________
# metadados 
url <- "https://servicodados.ibge.gov.br/api/v3/agregados/8695/metadados"
# carregar todos os metadados
serie <- fromJSON(url)
# filtrar o nivel territorial
nivel_territorial <- serie$nivelTerritorial$Administrativo
# filtrar as variaveis
variaveis <- serie$variaveis
# ajustar o nome das variaveis
variaveis$nome <- gsub("PMS - ","",variaveis$nome)
# filtrar as categorias
categorias <- serie$classificacoes$categorias[[1]]
# filtrar as atividades
atividades <- serie$classificacoes$categorias[[2]]
# url das localidades
url_loc <- "https://servicodados.ibge.gov.br/api/v3/agregados/8695/localidades/N1"
# carregar as localidades
localidades <- fromJSON(url_loc)
# dividir as bases
localidades1 <- localidades[,c("id","nome")]
# renomear as colunas
colnames(localidades1) <- c("id_loc","nome_loc")
# criar a segunda base
localidades2 <- localidades$nivel
# renomear a base de localidades 2
colnames(localidades2) <- c("id_nivel","nome_nivel")
# unir as bases novamente
localidades <- cbind(localidades1, localidades2)
# criar a funcao que simula a classe cadastroSeries existente no app
cadastroSeries <- function(numero, nome, nomeCompleto, descricao, formato, fonte, urlAPI, idAssunto, periodicidade, metrica, nivelGeografico, localidades,
                           categoria){
  
  return(paste0("cadastroSeries(",numero,",'",nome,"','",nomeCompleto,"','",descricao,"','",formato,"','",fonte,"','",urlAPI,"',",idAssunto,",'",periodicidade,"','",metrica,
                "','",nivelGeografico,"','",localidades,"','",categoria,"'),"))
  
}
# criar variavel com o ultimo numero de serie inserido manualmente no app
numero_ini <- 209737
# criar lista vazia
lista_dados <- list()
# preencher a lista com as series
for(i in 1:nrow(variaveis)){
  for(j in 1:nrow(localidades)){
    for(w in 1:nrow(categorias)){
      for(k in 1:nrow(atividades)){
        numero_ini <- numero_ini+1
        if(i%in%grep("índice",variaveis$nome)){
          unidade <- variaveis[i,"nome"]
        } else {
          unidade <- "%"
        }
        lista_dados[[as.character(numero_ini)]] <- cadastroSeries(numero_ini, 
                                                                  "Pesquisa Mensal de Serviços",
                                                                  "Pesquisa Mensal de Serviços",
                                                                  "A Pesquisa Mensal de Serviços produz indicadores que permitem acompanhar o comportamento conjuntural do setor de serviços no País, investigando a receita bruta de serviços nas empresas formalmente constituídas, com 20 ou mais pessoas ocupadas, que desempenham como principal atividade um serviço não financeiro, excluídas as áreas de saúde e educação.",
                                                                  unidade,
                                                                  "IBGE",
                                                                  paste0("https://servicodados.ibge.gov.br/api/v3/agregados/8695/periodos/all/variaveis/",variaveis[i,"id"],"?localidades=",localidades[j,"id_nivel"],"[",localidades[j,"id_loc"],"]&classificacao=11046[",categorias[w,"id"],"]|12355[",atividades[k,"id"],"]"),
                                                                  2,
                                                                  "mensal",
                                                                  variaveis[i,"nome"],
                                                                  localidades[j,"nome_nivel"],
                                                                  localidades[j,"nome_loc"],
                                                                  paste0(categorias[w,"nome"], " - ", atividades[k,"nome"]))
      }
    }
  }
}
# transformar em data.frame
pimpf <- do.call("rbind",lista_dados)
pimpf <- as.data.frame(pimpf)
# apagar o numero das linhas
row.names(pimpf) <- NULL
# exportar como csv
write.csv(pimpf, file="C:/Users/Kleber/Documents/pms8695.csv", row.names = F)
