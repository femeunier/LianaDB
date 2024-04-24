insert.site <- function(myDB,
                            id, name = "''", country = "''",
                            lat = "NULL", lon = "NULL"){
  dbSendQuery(myDB,
              paste0("INSERT INTO sites (id, name, country, lat, lon) VALUES (",
                     id,",",
                     "'",name,"', ",
                     "'",country,"', ",
                     "'",lat,"', ",
                     "'",lon,"');"))
}
