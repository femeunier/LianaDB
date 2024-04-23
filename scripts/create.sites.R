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

file2read <- "./data/sites.csv"
data <- read.csv(file2read) %>%
  dplyr::select(-any_of(c("Record.creator")))

data[is.na(data)] <- "NULL"

# # creating a table
all.tables <-
  dbListTables(myDB)

if (!("sites" %in% all.tables)){

  dbSendQuery(myDB, "CREATE TABLE sites(
                         id INT(10),
                         name VARCHAR(200),
                         country VARCHAR(200),
                         lat FLOAT(1),
                         lon FLOAT(1)
            )")

} else {
  dbRemoveTable(myDB,"sites")

  dbSendQuery(myDB, "CREATE TABLE sites(
                         id INT(10),
                         name VARCHAR(200),
                         country VARCHAR(200),
                         lat FLOAT(1),
                         lon FLOAT(1)
            )")

  empty.table(myDB,"sites")
}

print("Creating sites table")

for (irow in seq(1,nrow(data))){

  # print(irow)

  cauthor <- data[irow,1]
  cYear <- data[irow,2]
  cVol <- data[irow,5]


  dbSendQuery(myDB,
              paste0("INSERT INTO sites (id, name, country, lat, lon) VALUES (",
                     irow,",",
                     "'",data[irow,1],"', ",
                     "'",data[irow,2],"', ",
                     "'",data[irow,3],"', ",
                     "'",data[irow,4],"');")
  )}

sites <- get.table(myDB,"sites")
dbDisconnectAll()
