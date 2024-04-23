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

file2read <- "./data/treatment.csv"
data <- read.csv(file2read) %>%
  dplyr::select(-any_of(c("Record.creator")))

data[is.na(data)] <- "NULL"

# # creating a table
all.tables <-
  dbListTables(myDB)

if (!("treatment" %in% all.tables)){

  dbSendQuery(myDB, "CREATE TABLE treatment(
                         id INT(10),
                         name VARCHAR(200),
                         description VARCHAR(200),
                         control ENUM('yes', 'no'),
                         notes LONGTEXT
              )")

} else {
  dbRemoveTable(myDB,"treatment")

  dbSendQuery(myDB, "CREATE TABLE treatment(
                         id INT(10),
                         name VARCHAR(200),
                         description VARCHAR(200),
                         control ENUM('yes', 'no'),
                         notes LONGTEXT
            )")

  empty.table(myDB,"treatment")
}

print("Creating treatments table")

for (irow in seq(1,nrow(data))){

  # print(irow)

  dbSendQuery(myDB,
              paste0("INSERT INTO treatment (id, name, description, control, notes) VALUES (",
                     irow,",",
                     "'",data[irow,1],"', ",
                     "'",data[irow,2],"', ",
                     "'",data[irow,3],"', ",
                     "'",data[irow,4],"');")
  )}


treatment <- get.table(myDB,"treatment")
dbDisconnectAll()
