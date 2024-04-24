insert.citation <- function(myDB,
                            id, author = "''", year = "NULL", title = "''", journal = "''",
                            vol = "NULL", page = "''", url = "''", doi = "''"){
  dbSendQuery(myDB,
            paste0("INSERT INTO citations (id, author, year, title, journal, vol, page, url, doi) VALUES (",
                   id,",",
                   "'",author,"', ",
                   year,",",
                   "'",title,"', ",
                   "'",journal,"', ",
                   vol,", ",
                   "'",page,"', ",
                   "'",url,"', ",
                   "'",doi,"');"))
}
