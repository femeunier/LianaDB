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

file2read <- "./data/variables.csv"
data <- read.csv(file2read) %>%
  dplyr::select(-any_of(c("Record.creator")))

data[is.na(data)] <- "NULL"

# # creating a table
all.tables <-
  dbListTables(myDB)

if (!("variables" %in% all.tables)){

  dbSendQuery(myDB, "CREATE TABLE variables(
                         id INT(10),
                         name VARCHAR(200),
                         description VARCHAR(200),
                         units VARCHAR(200),
                         notes LONGTEXT
            )")

} else {
  dbRemoveTable(myDB,"variables")

  dbSendQuery(myDB, "CREATE TABLE variables(
                         id INT(10),
                         name VARCHAR(200),
                         description VARCHAR(200),
                         units VARCHAR(200),
                         notes LONGTEXT
            )")

  empty.table(myDB,"variables")
}

print("Creating variables table")

for (irow in seq(1,nrow(data))){

  # print(irow)

  dbSendQuery(myDB,
              paste0("INSERT INTO variables (id, name, description, units, notes) VALUES (",
                     irow,",",
                     "'",data[irow,1],"', ",
                     "'",data[irow,2],"', ",
                     "'",data[irow,3],"', ",
                     "'",data[irow,4],"');")
  )}


variables <- get.table(myDB,"variables")
dbDisconnectAll()
