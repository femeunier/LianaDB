remove.citation <- function(myDB,
                            id){

  dbSendQuery(myDB,
              paste0("DELETE FROM citations WHERE id=",id,";"))

}
