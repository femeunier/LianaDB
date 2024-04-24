remove.site <- function(myDB,
                            id){

  dbSendQuery(myDB,
              paste0("DELETE FROM sites WHERE id=",id,";"))

}
