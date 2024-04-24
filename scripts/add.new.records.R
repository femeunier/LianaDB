rm(list = ls())

library(RMySQL)
library(LianaDB)
library(plyr)
library(stringr)
library(dplyr)
library(tidyr)

# Add new trait records

# Step 1: Add citation

myDB = dbConnect(RMySQL::MySQL(),
                 dbname='LianaDB',
                 host='localhost',
                 port=3306,
                 user='user',
                 password='P@ssw0rld!')
citations <- get.table(myDB,"citations")

new.record <- data.frame(author = "Slot et al.",
                         year = 2014,
                         title = "Trait-based scaling of temperature-dependent foliar respiration in a species-rich tropical forest canopy",
                         journal = "Functional ecology",
                         vol = 28,
                         page = "1074–1086",
                         url = "https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/1365-2435.12263",
                         doi = "10.1111/1365-2435.12263")

newid <- max(citations[["id"]]) + 1

for (irow in seq(1,nrow(new.record))){

  if (!(new.record[["doi"]][irow] %in% citations[["doi"]])){
    insert.citation(myDB,
                    newid,
                    author = new.record[["author"]][irow],
                    year = new.record[["year"]][irow],
                    title = new.record[["title"]][irow],
                    journal = new.record[["journal"]][irow],
                    vol = new.record[["vol"]][irow],
                    page = new.record[["page"]][irow],
                    url = new.record[["url"]][irow],
                    doi = new.record[["doi"]][irow])
      newid <- newid + 1
  }
}

################################################################################
# Step 2: Add site

sites <- get.table(myDB,"sites")

new.record <- data.frame(name = "Parque Natural Metropolitano",
                         country = "Panama",
                         lat = 8.98,
                         lon = -79.55)
newid <- max(sites[["id"]]) + 1

for (irow in seq(1,nrow(new.record))){

  if (nrow(match_df(sites %>%
                 dplyr::select(name,country,lat,lon), new.record[irow,])) == 0){
    insert.site(myDB,
                newid,
                name = new.record[["name"]][irow],
                country = new.record[["country"]][irow],
                lat = new.record[["lat"]][irow],
                lon = new.record[["lon"]][irow])

    newid <- newid + 1
  }
}

################################################################################
# Step 3: Adding species

new.species <- read.csv("./data/new.species.csv",header = FALSE) %>%
  rename(short = V1,
         scientific.name = V2) %>%
  mutate(growthform = "liana",
         genus = stringr::word(scientific.name,1),
         species = stringr::word(scientific.name,2)) %>%
  filter(growthform == "liana")

species <- get.table(myDB,"species")
newid <- max(species[["id"]]) + 1

for (irow in seq(1,nrow(new.species))){

  if (nrow(match_df(species %>%
                    dplyr::select(scientific_name,
                                  genus,species) %>%
                    rename(scientific.name = scientific_name),
                    new.species[irow,] %>%
                    dplyr::select(scientific.name,genus,species))) == 0){
    insert.species(myDB,
                newid,
                genus = new.species[["genus"]][irow],
                growth_form = new.species[["growthform"]][irow],
                scientific_name = new.species[["scientific.name"]][irow],
                species = new.species[["species"]][irow])

    newid <- newid + 1
  }
}

################################################################################
# Step 4: create new variable

variables <- get.table(myDB,"variables")

new.record <- data.frame(name = "Q10",
                         description = "Proportional increase with 10 °C warming",
                         units = "-",
                         notes = "")
newid <- max(variables[["id"]]) + 1

for (irow in seq(1,nrow(new.record))){

  if (nrow(match_df(variables %>%
                    dplyr::select(name,description,units),
                    new.record[irow,] %>%
                    dplyr::select(name,description,units))) == 0){
    insert.variable(myDB,
                    newid,
                    name = new.record[["name"]][irow],
                    description = new.record[["description"]][irow],
                    notes = new.record[["notes"]][irow],
                    units = new.record[["units"]][irow])

    newid <- newid + 1
  }
}

################################################################################
# Additional steps: add covariate, treatment with the same method as above (not needed here)

################################################################################

trait.data <- read.csv("./data/new.traits.csv") %>%
  rename(short = Species) %>%
  left_join(new.species,
            by = "short") %>%
  group_by(scientific.name,species) %>%
  summarise(N = length(!is.na(Q10)),
            Q10 = mean(Q10,na.rm = TRUE),
            SLA = mean(SLA,na.rm = TRUE),
            .groups = "keep") %>%
  pivot_longer(cols = c("Q10","SLA"),
               names_to = "variable",
               values_to = "value") %>%
  mutate(site.name = "Parque Natural Metropolitano",
         GrowthForm = "liana",
         Reference = "Slot et al. 2014")

traits <- get.table(myDB,"traits")
newid <- max(traits[["id"]]) + 1


stop()
ccitation_id <- 34
csite_id <- 12
variables <- get.table(myDB,"variables")
species <- get.table(myDB,"species")

for (irow in seq(1,nrow(trait.data))){
  cvariable_id <- variables[which(variables[["name"]] == trait.data[["variable"]][irow]),
                            "id"]
  cspecies_id <- species[which(species[["scientific_name"]] == trait.data[["scientific.name"]][irow]
                               & species[["growth_form"]] == tolower(trait.data[["GrowthForm"]][irow])),
                         "id"]
  value <- trait.data[["value"]][irow]

  insert.trait(myDB,
               id = newid,
               variable_id = cvariable_id, site_id = csite_id, species_id = cspecies_id,
               citation_id = ccitation_id,
               treatment_id = 1, mean = value,
               N = trait.data[["N"]][irow])

  newid <- newid + 1

}



dbDisconnectAll()
