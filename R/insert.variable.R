insert.variable <- function(myDB,
                           id, name = "''", description = "''", units = "''",
                           notes = "''"){

  dbSendQuery(myDB,
              paste0("INSERT INTO variables (id, name, description, units, notes) VALUES (",
                     id,",",
                     "'",name,"', ",
                     "'",description,"', ",
                     "'",units,"', ",
                     "'",notes,"');"))
}



