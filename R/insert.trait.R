insert.trait <- function(myDB,
                         id, variable_id, site_id, species_id, citation_id,
                         treatment_id = 1, method = "''",
                         date = "'1000-01-01'", mean, N = 1, stat = "NULL",statname = "''",
                         notes = "''", covariate_id = "NULL"){

  dbSendQuery(myDB,
              paste0("INSERT INTO traits (id, variable_id, site_id, species_id, citation_id, treatment_id,method, date,
                     mean, N, stat, statname, notes, covariate_id) VALUES (",
                     id,",",
                     variable_id,",",
                     site_id,",",
                     species_id,",",
                     citation_id,",",
                     treatment_id,",",
                     method,",", # Method
                     date,",", # Date
                     mean,",",
                     N,",", # N
                     stat,",", # stat
                     statname,",", # statname
                     notes,",", # notes
                     covariate_id,");"))

}



