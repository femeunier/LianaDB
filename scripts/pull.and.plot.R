rm(list = ls())

library(dplyr)
library(ggplot2)
library(LianaDB)
library(RMySQL)
library(ggthemes)

myDB = dbConnect(RMySQL::MySQL(),
                 dbname='newLianaDB',
                 host='localhost',
                 port=3306,
                 user='user',
                 password='P@ssw0rld!')

traits <- get.table(myDB,"traits")
species <- get.table(myDB,"species") %>%
  rename(species_id = id)
sites <- get.table(myDB,"sites") %>%
  rename(site_id = id)
variables <- get.table(myDB,"variables") %>%
  rename(variable_id = id,
         variable_name = name)

# ################################################################################
# # Alternatively
# myDB <- readRDS("./databases/LianaDB.RDS")
# traits <- myDB[["traits"]]
# species <- myDB[["species"]]
# variables <- myDB[["variables"]]
# sites <- myDB[["sites"]]

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

################################################################################
# Table 1

all.df %>%
  filter(growth_form == "liana") %>%
  group_by(variable_name) %>%
  summarise(N = n(),
            Nref = length(unique(citation_id)),
            Nspecies = length(unique(species_id)),
            .groups = "keep")

###############################################################################
df.species <- all.df %>%
  group_by(scientific_name) %>%
  summarise(N = n(),
            .groups = "keep") %>%
  mutate(species.group = case_when(tolower(scientific_name) == "unknown" ~ "Other",
                                   N > 10 ~ scientific_name,
                                   TRUE ~ "Other")) %>%
  group_by(species.group) %>%
  summarise(N = sum(N),
            .groups = "keep") %>%
  arrange(desc(N))

ggplot(data = df.species %>%
         filter(species.group != "Other")) +
  geom_bar(aes(x = species.group,
               fill = species.group,
               y = N),
           stat = "identity") +
  theme_bw() +
  labs(x = "") +
  guides(fill = "none") +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))


###############################################################################
df.sites <- all.df %>%
  group_by(site_id) %>%
  summarise(N = n(),
            .groups = "keep") %>%
  left_join(sites,
            by = "site_id") %>%
  mutate(site.group = case_when(country == "Panama" ~ "Panama",
                                country == "Australia" & name != "New South Wales" ~ "Australia.group",
                                TRUE ~ name)) %>%
  group_by(site.group) %>%
  summarise(N = sum(N),
            lat = mean(lat),
            lon = mean(lon),
            .groups = "keep")


world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
df.r <- readRDS("./data/font.map.LU.RDS")

ggplot() +
  geom_raster(data = df.r,
              aes(x = lon, y = lat, fill = as.factor(LU)),
              alpha = 0.5,show.legend = FALSE) +
  geom_sf(data = world,
          fill = NA, color = "black") +
  geom_point(data = df.sites,
             aes(x=lon,y = lat,
                 size = N)) +
  labs(x = "",y = "") +
  scale_y_continuous(limits = c(-30,40)) +
  scale_x_continuous(limits = c(-120,160)) +
  scale_fill_manual(values = c("white",c("#72a83d"),"darkgreen")) +
  theme_map() +
  theme(text = element_text(size = 20),
        strip.background = element_blank(),
        strip.text = element_blank()) +
  guides(size = "none")


