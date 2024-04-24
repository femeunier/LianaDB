insert.species <- function(myDB,
                           id, genus = "''", species = "''", scientific_name = "''",
                            growth_form = "liana"){

  dbSendQuery(myDB,
              paste0("INSERT INTO species (id, genus, species, scientific_name, growth_form) VALUES (",
                     id,",",
                     "'",genus,"', ",
                     "'",species,"', ",
                     "'",scientific_name,"', ",
                     "'",growth_form,"');")
  )
}



