empty.table <- function(DB,table){
  dbSendQuery(DB, paste0("truncate table ",table,";"))
}
