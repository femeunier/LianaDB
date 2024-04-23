rm(list = ls())

library(RMySQL)
library(dplyr)
library(LianaDB)

myDB = dbConnect(RMySQL::MySQL(),
                 dbname='LianaDB',
                 host='localhost',
                 port=3306,
                 user='user',
                 password='P@ssw0rld!')

dbListTables(myDB)

file2read <- "./data/citations.csv"
data <- read.csv(file2read) %>%
  dplyr::select(-any_of(c("Record.creator")))

data[is.na(data)] <- "NULL"

# # creating a table
all.tables <-
  dbListTables(myDB)

if (!("citations" %in% all.tables)){

  dbSendQuery(myDB, "CREATE TABLE citations(
                         id INT(10),
                         author VARCHAR(200),
                         year YEAR,
                         title VARCHAR(1000),
                         journal VARCHAR(2000),
                         vol INT,
                         page VARCHAR(20),
                         url VARCHAR(2083),
                         doi VARCHAR(2083)
            )")

} else {
  dbRemoveTable(myDB,"citations")

  dbSendQuery(myDB, "CREATE TABLE citations(
                         id INT(10),
                         author VARCHAR(200),
                         year YEAR,
                         title VARCHAR(1000),
                         journal VARCHAR(2000),
                         vol INT,
                         page VARCHAR(20),
                         url VARCHAR(2083),
                         doi VARCHAR(2083)
            )")

  empty.table(myDB,"citations")
}



print("Creating citations table")

for (irow in seq(1,nrow(data))){

  # print(irow)

  cauthor <- data[irow,1]
  cYear <- data[irow,2]
  cVol <- data[irow,5]


  dbSendQuery(myDB,
  paste0("INSERT INTO citations (id, author, year, title, journal, vol, page, url, doi) VALUES (",
         irow,",",
        "'",cauthor,"', ",
        cYear,",",
        "'",data[irow,3],"', ",
        "'",data[irow,4],"', ",
        cVol,", ",
        "'",data[irow,6],"', ",
        "'",data[irow,7],"', ",
        "'",data[irow,8],"');")
  )}


citations <- get.table(myDB,"citations")

dbDisconnectAll()
