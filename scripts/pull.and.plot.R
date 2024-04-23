rm(list = ls())

library(dplyr)
library(ggplot2)
library(LianaDB)

myDB = dbConnect(RMySQL::MySQL(),
                 dbname='newLianaDB',
                 host='localhost',
                 port=3306,
                 user='user',
                 password='P@ssw0rld!')


traits <- get.table(myDB,"traits")
species <- get.table(myDB,"species") %>%
  rename(species_id = id)
variables <- get.table(myDB,"variables") %>%
  rename(variable_id = id,
         variable_name = name)


all.df <- traits %>%
  left_join(species,
            by = "species_id") %>%
  left_join(variables,
            by = "variable_id")

ggplot(data = all.df) +
  geom_boxplot(aes(x = growth_form, fill = growth_form,
                   y = mean)) +
  facet_wrap(~ variable_name, scales = "free_y") +
  theme_bw()

all.df %>%
  filter(growth_form == "liana") %>%
  group_by(variable_name) %>%
  summarise(N = n(),
            Nref = length(unique(citation_id)),
            Nspecies = length(unique(species_id)))
