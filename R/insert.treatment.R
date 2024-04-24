insert.treatment <- function(myDB,
                           id, name = "''", description = "''", control = "yes",
                           notes = "''"){

  dbSendQuery(myDB,
              paste0("INSERT INTO treatment (id, name, description, control, notes) VALUES (",
                     id,",",
                     "'",name,"', ",
                     "'",description,"', ",
                     "'",control,"', ",
                     "'",notes,"');"))
}



