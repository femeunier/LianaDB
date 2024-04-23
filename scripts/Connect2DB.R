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

all.tables <- dbListTables(myDB)

s <- paste0("select * from ", all.tables[1])
rs <- dbSendQuery(myDB, s)
df <-  fetch(rs, n = -1)

dbDisconnectAll()
