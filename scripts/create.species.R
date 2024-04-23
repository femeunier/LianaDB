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

dbListTables(myDB)

file2read <- c("./data/All_Amax.csv",
               "./data/All_PVtraits.csv",
               "./data/All_xylemVC.csv",
               "./data/Panama_post 2_1.csv")
data <- bind_rows(read.csv(file2read[1]) %>%
  dplyr::select(Species,GrowthForm),
  read.csv(file2read[2]) %>%
    dplyr::select(Species,GrowthForm),
  read.csv(file2read[3]) %>%
    dplyr::select(Species,GrowthForm),
  read.csv(file2read[4]) %>%
    dplyr::select(Species,Growth.form) %>%
    rename(GrowthForm = Growth.form)) %>%
  distinct() %>%
  mutate(growthform = tolower(GrowthForm),
         genus = stringr::word(Species,1),
         species = stringr::word(Species,2)) %>%
  rename(scientific.name = Species) %>%
  dplyr::select(scientific.name,genus,species,growthform) %>%
  filter(growthform == "liana")

data[is.na(data)] <- "NULL"

# # creating a table
all.tables <-
  dbListTables(myDB)

if (!("species" %in% all.tables)){

  dbSendQuery(myDB, "CREATE TABLE species(
                         id INT(10),
                         genus VARCHAR(200),
                         species VARCHAR(200),
                         scientific_name VARCHAR(200),
                         growth_form ENUM('liana', 'tree', 'grass', 'shrub')
            )")

  empty.table(myDB,"species")

} else {
  dbRemoveTable(myDB,"species")

  dbSendQuery(myDB, "CREATE TABLE species(
                         id INT(10),
                         genus VARCHAR(200),
                         species VARCHAR(200),
                         scientific_name VARCHAR(200),
                         growth_form ENUM('liana', 'tree', 'grass', 'shrub')
            )")

  empty.table(myDB,"species")
}

print("Creating Species table")

for (irow in seq(1,nrow(data))){

  # print(irow)

  dbSendQuery(myDB,
              paste0("INSERT INTO species (id, genus, species, scientific_name, growth_form) VALUES (",
                     irow,",",
                     "'",data[irow,2],"', ",
                     "'",data[irow,3],"', ",
                     "'",data[irow,1],"', ",
                     "'",data[irow,4],"');")
  )
}

species <- get.table(myDB,"species")
dbDisconnectAll()
