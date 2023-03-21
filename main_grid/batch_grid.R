library(lubridate)
library(dplyr)
library(Hmisc)
library(VarSelLCM) 
library(kamila)
library(poLCA)
library(reshape)
library(ggplot2)
library(reshape2)
library(seriation)
library(statnet)
library(igraph)
library(nnet)
library(VGAM)

source('~/Documents/git/rebelTrack2/main/ingester_grid.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main/rebel_best_ged_grid.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main/rebel_days_ged_grid.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main/rebel_deathsA_ged_grid.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main/rebel_deathsB_ged_grid.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main/rebel_distance_ged_grid.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main/rebel_events_ged_grid.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main/rebel_grids_ged_grid.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main/rebel_transnational_ged_grid.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main/merge_grid.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main/rebel_adjacency_ged_grid.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main/slag_grid.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main/lag_grid.R', chdir = TRUE)