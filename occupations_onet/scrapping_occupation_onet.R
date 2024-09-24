library(rvest)
library(openxlsx)
library(dplyr)



ONET_Occupations <- read.xlsx("https://www.onetonline.org/find/descriptor/result/2.B.2.i/Complex_Problem_Solving.xlsx?fmt=xlsx") %>%
  select(4,5)

colnames(ONET_Occupations) <- ONET_Occupations[2,]
ONET_Occupations <- ONET_Occupations[-c(1:2),]


rows <- list()

for ( i in ONET_Occupations$Code) {

url <- paste0("https://www.onetonline.org/link/summary/", i)

Description <- read_html(url) %>%
  html_nodes(xpath = '//*[@id="content"]/p[1]') %>%
  html_text()

scrapped <- data.frame(Code = i, Description)

rows[[i]] <- scrapped

}

jbz <- read.xlsx("https://www.onetonline.org/find/all/All_Occupations.xlsx?fmt=xlsx")
colnames(jbz) <- jbz[1,]
jbz <- jbz[-1,-4] %>%
  select(2,3,1)
  
  
data <- do.call(rbind, rows) %>%
  left_join(jbz, by = "Code") %>%
  rename(Title = Occupation)

rownames(data) <- NULL

saveRDS(data, "onet description.rds")



