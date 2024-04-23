rm(list = ls())

library(RMySQL)
library(dplyr)
library(stringr)
library(LianaDB)

myDB = dbConnect(RMySQL::MySQL(),
                 dbname='LianaDB',
                 host='localhost',
                 port=3306,
                 user='user',
                 password='P@ssw0rld!')


all.tables <- dbListTables(myDB)

if (!("covariates" %in% all.tables)){

  dbSendQuery(myDB, "CREATE TABLE covariates(
                         id INT(10),
                         variable VARCHAR(200),
                         level FLOAT(1),
                         stat  FLOAT(1),
                         statname VARCHAR(200)
            )")

  empty.table(myDB,"covariates")

} else {
  dbRemoveTable(myDB,"covariates")

  dbSendQuery(myDB, "CREATE TABLE covariates(
                         id INT(10),
                         variable VARCHAR(200),
                         level FLOAT(1),
                         stat  FLOAT(1),
                         statname VARCHAR(200)
            )")

  empty.table(myDB,"covariates")
}


print("Creating covariates table")

covariates <- get.table(myDB,"covariates")
dbDisconnectAll()
