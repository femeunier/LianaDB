get.table <- function(DB,table){

  rs <- dbSendQuery(DB, paste0("select * from ", table))
  df <-  fetch(rs, n = -1)
  return(df)
}
