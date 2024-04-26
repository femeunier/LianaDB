rm(list = ls())

# Prerequisites: MySQL, RMySQL and LianaDB installed

library(RMySQL)
library(LianaDB)

################################################################################
# Option 1: Import database
# sudo mysql
# CREATE DATABASE LianaDB;
# GRANT ALL PRIVILEGES ON * . * TO 'user'@'localhost';
# mysql --user root --password LianaDB < LianaDB.sql

################################################################################
# Option 2: create from scratch
# Preliminary steps (Linux)
# sudo mysql
# CREATE USER 'user'@'localhost' IDENTIFIED BY 'P@ssw0rld!';
# CREATE DATABASE LianaDB;
# GRANT ALL PRIVILEGES ON * . * TO 'user'@'localhost';

source("./scripts/create.citations.R")
source("./scripts/create.species.R")
source("./scripts/create.variables.R")
source("./scripts/create.sites.R")
source("./scripts/create.treatment.R")
source("./scripts/create.covariates.R")
source("./scripts/create.traits.R")

################################################################################
# Option 3: use R files
# LianaDB <- list(citations = get.table(myDB,"citations"),
#                 sites = get.table(myDB,"sites"),
#                 species = get.table(myDB,"species"),
#                 traits = get.table(myDB,"traits"),
#                 variables = get.table(myDB,"variables"),
#                 treatment = get.table(myDB,"treatment"),
#                 covariates = get.table(myDB,"covariates"))
saveRDS(LianaDB,
        "./databases/LianaDB.RDS")

LianaDB <- readRDS("./databases/LianaDB.RDS")

# save Database
# setwd("./databases/")
# system2("mysqldump",c("-uuser -pP@ssw0rld! LianaDB > LianaDB.sql"))
