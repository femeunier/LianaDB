remove.covariate <- function(myDB,
                             id){

  dbSendQuery(myDB,
              paste0("DELETE FROM covariates WHERE id=",id,";"))

}
