remove.treatment <- function(myDB,
                             id){

  dbSendQuery(myDB,
              paste0("DELETE FROM treatment WHERE id=",id,";"))

}
