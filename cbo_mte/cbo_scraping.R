rm(list=ls())

library(openxlsx)
library(dplyr)
library(rvest)
library(curl)


cbo_familia <- read.csv2("cbo_mte/ESTRUTURA CBO/CBO2002 - Familia.csv", sep = ";", fileEncoding = "latin1") %>%
  mutate(TITULO = gsub("[./-]", "", TITULO),
         TITUTLO_SCRAP = gsub(" ", "-", tolower(iconv(TITULO, from = "UTF-8", to = "ASCII//TRANSLIT"))))


rows <- list()

for (i in 1:nrow(cbo_familia)) {
  
  url <- paste0("https://www.ocupacoes.com.br/cbo-mte/", cbo_familia$CODIGO[i], "-", cbo_familia$TITUTLO_SCRAP[i])
  
  Description <- NA
  Experience <- NA
  
  tryCatch({
    
    Description <- read_html(url) %>%
      html_nodes(xpath = '//*[@id="container-principal"]/section/text()') %>%
      html_text(trim = TRUE)
    
    Experience <- read_html(url) %>%
      html_nodes(xpath = '//*[@id="container-principal"]/section/text()') %>%
      html_text(trim = TRUE)

    
  }, error = function(e) {
    
  })
  
  
  scrapped <- data.frame(CODIGO = cbo_familia$CODIGO[i],  Description = Description[8], 
                         Experience = Experience[9])
  
  
  rows[[i]] <- scrapped

}


data <- do.call(rbind, rows)
  

saveRDS(data, "cbo description.rds")


