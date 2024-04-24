rm(list = ls())

library(dplyr)
library(ggplot2)
library(LianaDB)
library(RMySQL)
library(ggthemes)
library(tidyr)

myDB = dbConnect(RMySQL::MySQL(),
                 dbname='LianaDB',
                 host='localhost',
                 port=3306,
                 user='user',
                 password='P@ssw0rld!')

traits <- get.table(myDB,"traits")
species <- get.table(myDB,"species") %>%
  dplyr::rename(species_id = id)
sites <- get.table(myDB,"sites") %>%
  dplyr::rename(site_id = id,
         site_name = name)
variables <- get.table(myDB,"variables") %>%
  dplyr::rename(variable_id = id,
         variable_name = name)
citations <- get.table(myDB,"citations")

# ################################################################################
# # Alternatively
# myDB <- readRDS("./databases/LianaDB.RDS")
# traits <- myDB[["traits"]]
# species <- myDB[["species"]] %>%
# dplyr::rename(species_id = id)
# variables <- myDB[["variables"]] %>%
# dplyr::rename(variable_id = id,
# variable_name = name)
# sites <- myDB[["sites"]] %>%
# dplyr::rename(site_id = id,
# site_name = name)
# citations <- myDB[["citations"]]

all.df <- traits %>%
  left_join(species,
            by = "species_id") %>%
  left_join(variables,
            by = "variable_id") %>%
  left_join(sites %>%
              dplyr::select(site_id,site_name,lat,lon,country),
            by = "site_id") %>%
  mutate(mean.transform = case_when(variable_name %in% c("ks","kl","Al.As") ~ log10(mean),
                          TRUE ~ mean))

ggplot(data = all.df) +
  geom_violin(aes(x = growth_form,
                   fill = growth_form,
                   y = mean.transform),
              width=0.5) +
  geom_boxplot(aes(x = growth_form,
                   y = mean.transform),
               fill = NA,
               width=0.1,
               color = "black",
               alpha = 1) +
  facet_wrap(~ variable_name, scales = "free_y") +
  theme_bw() +
  labs(x = "") +
  guides(fill = "none")

################################################################################
# Table 2

all.df %>%
  filter(growth_form == "liana") %>%
  group_by(variable_name) %>%
  dplyr::summarise(m = mean(mean,na.rm = TRUE),
            Min = min(mean,na.rm = TRUE),
            Max = max(mean,na.rm = TRUE),

            N = n(),
            Nref = length(unique(citation_id)),
            Nspecies = length(unique(species_id)),
            .groups = "keep") %>%
  mutate(value = paste0(round(m, digits = 2),"\r\n",
                        "(",round(Min, digits = 2)," - ",round(Max, digits = 2),")")) %>%
  mutate(ref = paste0(N," - ",Nspecies," - ",Nref)) %>%
  left_join(variables,
            by = "variable_name") %>%
  dplyr::select(variable_name,units,description,value,ref)

###############################################################################
# Barplot per species

df.species <- all.df %>%
  group_by(scientific_name) %>%
  dplyr::summarise(N = n(),
            .groups = "keep") %>%
  mutate(species.group = case_when(tolower(scientific_name) == "unknown" ~ "Other",
                                   N > 10 ~ scientific_name,
                                   TRUE ~ "Other")) %>%
  group_by(species.group) %>%
  dplyr::summarise(N = sum(N),
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
# Worldmap with N

df.sites <- all.df %>%
  group_by(site_id,site_name,country,lat,lon) %>%
  dplyr::summarise(N = n(),
            .groups = "keep") %>%
  mutate(site.group = case_when(country == "Panama" ~ "Panama",
                                country == "Australia" & site_name != "New South Wales" ~ "Australia.group",
                                TRUE ~ site_name)) %>%
  group_by(site.group) %>%
  dplyr::summarise(N = sum(N),
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

################################################################################
# Example of relationship

selected.var <- variables %>%
  filter(variable_name %in% c("WD","ks"))

selected.traits <- all.df %>%
  filter(variable_id %in% selected.var[["variable_id"]])

selected.traits.sum <- selected.traits %>%
  group_by(variable_name,species_id,citation_id,site_name,treatment_id) %>%
  dplyr::summarise(mean.m = mean(mean,na.rm = TRUE),
            .groups = "keep") %>%
  pivot_wider(names_from = variable_name,
              values_from = mean.m)

ggplot(data = selected.traits.sum,
       aes(x = WD,
           y = log10(ks))) +
  geom_point(aes(color = as.factor(site_name))) +
  stat_smooth(method = "lm",
              color = "black",
              fill = "lightgrey") +
  theme_bw()

summary(lm(data = selected.traits.sum,
           formula = log10(ks) ~ WD))

dbDisconnectAll()
