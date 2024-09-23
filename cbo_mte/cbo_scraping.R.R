rm(list=ls())

library(openxlsx)
library(dplyr)
library(rvest)


CBO_Ocupações <- read.xlsx("Estrutura CBO Ocupação.xlsx") %>%
  mutate(TITULO = gsub("[./-]", "", TITULO),
         TITUTLO_SCRAP = gsub(" ", "-", tolower(iconv(TITULO, from = "UTF-8", to = "ASCII//TRANSLIT"))))


rows <- list()

for (i in 1:nrow(CBO_Ocupações)) {
  
  url <- paste0("https://codigocbo.com.br/cbo-", CBO_Ocupações$CODIGO[i], "-", CBO_Ocupações$TITUTLO_SCRAP[i])
  
  Description <- NA
  
  tryCatch({
    
    Description <- read_html(url) %>%
      html_nodes(xpath = '/html/body/div/div/div/div/div/div[4]') %>%
      html_text()
    
    if (length(Description) == 0) {
      Description <- NA 
    }
    
    
  }, error = function(e) {
    
  })
  
  
  scrapped <- data.frame(CODIGO = CBO_Ocupações$CODIGO[i],  Description = ifelse(is.na(Description), "Sem descrição", Description))
  
  
  rows[[i]] <- scrapped
}


data <- do.call(rbind, rows) %>%
  mutate(Description = gsub("Descrição Sumária:", "", Description),
         Description = gsub("\r|\n", " ", Description),
         Description = gsub("\\s+", " ", Description)) %>%
  left_join(CBO_Ocupações, by = "CODIGO") %>%
  select(1,3,2) %>%
  rename(Code = CODIGO,
         Title = TITULO)
  

saveRDS(data, "cbo description.rds")


