library(RMySQL)
library(dplyr)
library(ggplot2)
library(tidyr)
library(LianaDB)
library(stringr)

myDB = dbConnect(RMySQL::MySQL(),
                 dbname='LianaDB',
                 host='localhost',
                 port=3306,
                 user='user',
                 password='P@ssw0rld!')

citations <- get.table(myDB,"citations")
citations[is.na(citations)] <- ""
species <- get.table(myDB,"species")
sites <- get.table(myDB,"sites")
variables <- get.table(myDB,"variables")

file2read1 <- c("./data/All_Amax.csv")
trait.data1 <- read.csv(file2read1) %>%
  mutate(lat = round(Lat,digits = 2),
         lon = round(Long,digits = 2)) %>%
  left_join(sites %>%
              dplyr::select(lat,lon,name) %>%
              rename(site.name = name),
            by = c("lat","lon")) %>%
  dplyr::select(Species,GrowthForm,amax,wd,sla,Reference,site.name) %>%
  rename(Aarea = amax,
         SLA = sla,
         WD = wd) %>%
  pivot_longer(cols = c("Aarea","WD","SLA"),
               names_to = "variable",
               values_to = "value") %>%
  filter(!is.na(value)) %>%
  filter(GrowthForm == "Liana")

file2read2 <- c("./data/All_xylemVC.csv")
trait.data2 <- read.csv(file2read2) %>%
  mutate(lat = round(Lat,digits = 2),
         lon = round(Long,digits = 2)) %>%
  left_join(sites %>%
              dplyr::select(lat,lon,name) %>%
              rename(site.name = name),
            by = c("lat","lon")) %>%
  dplyr::select(Species,GrowthForm,kl,ksat,Al.As,ax,p50,wd,sla,Reference,site.name,lat,lon) %>%
  rename(P50 = p50,
         ks = ksat,
         SLA = sla,
         WD = wd) %>%
  pivot_longer(cols = c("kl","ks","Al.As","P50","ax","SLA","WD"),
               names_to = "variable",
               values_to = "value") %>%
  filter(!is.na(value)) %>%
  filter(GrowthForm == "Liana")


file2read3 <- c("./data/All_PVtraits.csv")
trait.data3 <- read.csv(file2read3) %>%
  mutate(lat = round(Lat,digits = 2),
         lon = round(Long,digits = 2)) %>%
  left_join(sites %>%
              dplyr::select(lat,lon,name) %>%
              rename(site.name = name),
            by = c("lat","lon")) %>%
  dplyr::select(Species,GrowthForm,tlp,Cft,sla,wd,Reference,site.name,lat,lon,Organ) %>%
  rename(Ptlp = tlp,
         SLA = sla,
         WD = wd) %>%
  pivot_longer(cols = c("Ptlp","WD","SLA","Cft"),
               names_to = "variable",
               values_to = "value") %>%
  filter(!is.na(value)) %>%
  filter(GrowthForm == "Liana") %>%
  mutate(variable = case_when(variable %in% c("Ptlp") & Organ == "Xylem" ~ "Ptlp_wood",
                              variable %in% c("Ptlp") & Organ == "Leaf" ~ "Ptlp_leaf",
                              variable %in% c("Cft") & Organ == "Xylem" ~ "Cft_wood",
                              variable %in% c("Cft") & Organ == "Leaf" ~ "Cft_leaf",
                              TRUE ~ variable))


trait.data4 <- read.csv("./data/Panama_post 2_1.csv") %>%
  mutate(lat = case_when(Site.Name == "PNM" ~ 8.98,
                         TRUE ~ 9.28),
         lon = case_when(Site.Name == "PNM" ~ -79.55,
                         TRUE ~ -79.97)) %>%
  left_join(sites %>%
              dplyr::select(lat,lon,name) %>%
              rename(site.name = name),
            by = c("lat","lon")) %>%
  dplyr::select(site.name,Species,Growth.form,Amax,Vcmax25,Jmax25,LMA,Nmass,Cmass,Pmass,wood.density) %>%
  mutate_at(c("Amax","Vcmax25","Jmax25","LMA","Nmass","Cmass","Pmass","wood.density"),as.numeric) %>%
  rename(Aarea = Amax,
         GrowthForm = Growth.form,
         WD = wood.density) %>%
  mutate(SLA = 1/(LMA)*1000) %>%
  dplyr::select(-LMA) %>%
  pivot_longer(cols = c("Aarea","WD","Vcmax25","Jmax25","SLA","Nmass","Pmass","Cmass"),
               names_to = "variable",
               values_to = "value") %>%
  filter(!is.na(value)) %>%
  filter(GrowthForm == "liana") %>%
  mutate(Reference = "Lianhong et al. 2021")

trait.data <- bind_rows(trait.data1,
                        trait.data2,
                        trait.data3,
                        trait.data4)


# # creating a table
all.tables <-
  dbListTables(myDB)

if (!("traits" %in% all.tables)){

  dbSendQuery(myDB, "CREATE TABLE traits(
                         id INT(10),
                         variable_id INT(10),
                         site_id INT(10),
                         species_id INT(10),
                         citation_id INT(10),
                         citation_id INT(10),
                         method VARCHAR(200),
                         date DATE DEFAULT NULL,
                         mean FLOAT(1),
                         N INT,
                         stat  FLOAT(1),
                         statname VARCHAR(200),
                         notes LONGTEXT,
                         covariate_id INT(10)
            )")

} else {
  dbRemoveTable(myDB,"traits")

  dbSendQuery(myDB, "CREATE TABLE traits(
                         id INT(10),
                         variable_id INT(10),
                         site_id INT(10),
                         species_id INT(10),
                         citation_id INT(10),
                         treatment_id INT(10),
                         method VARCHAR(200),
                         date DATE DEFAULT NULL,
                         mean FLOAT(1),
                         N INT,
                         stat  FLOAT(1),
                         statname VARCHAR(200),
                         notes LONGTEXT,
                         covariate_id INT(10)
            )")

  empty.table(myDB,"traits")
}


print("Creating trait table")

for (irow in seq(1,nrow(trait.data))){

  # print(irow)
  cvariable_id <- variables[which(variables[["name"]] == trait.data[["variable"]][irow]),
                            "id"]
  cspecies_id <- species[which(species[["scientific_name"]] == trait.data[["Species"]][irow]
                               & species[["growth_form"]] == tolower(trait.data[["GrowthForm"]][irow])),
                         "id"]
  ccitation_id <- citations[which(str_trim(paste(citations[["author"]],
                                        citations[["year"]])) == trait.data[["Reference"]][irow]),
                            "id"]
  csite_id <- sites[which(sites[["name"]] == trait.data[["site.name"]][irow]),
                    "id"]
  value <- trait.data[["value"]][irow]

  # print(c(cvariable_id,cspecies_id,ccitation_id,csite_id))
  # View(trait.data[irow,])

  dbSendQuery(myDB,
              paste0("INSERT INTO traits (id, variable_id, site_id, species_id, citation_id, treatment_id,method, date,
                     mean, N, stat, statname, notes, covariate_id) VALUES (",
                     irow,",",
                     cvariable_id,",",
                     csite_id,",",
                     cspecies_id,",",
                     ccitation_id,",",
                     1,",",
                     "''",",", # Method
                     "'1000-01-01'",",", # Date
                     value,",",
                     "NULL",",", # N
                     "NULL",",", # stat
                     "''",",", # statname
                     "''",",", # notes
                     "NULL",");")
  )
}



traits <- get.table(myDB,"traits")

dbDisconnectAll()
