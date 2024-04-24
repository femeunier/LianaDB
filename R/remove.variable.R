remove.variable <- function(myDB,
                            id){

  dbSendQuery(myDB,
              paste0("DELETE FROM variables WHERE id=",id,";"))

}
