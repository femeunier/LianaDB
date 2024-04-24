remove.species <- function(myDB,
                            id){

  dbSendQuery(myDB,
              paste0("DELETE FROM species WHERE id=",id,";"))

}
