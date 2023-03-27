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

source('~/Documents/git/rebelTrack2/main_grid_half/actors_grid.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main_grid_half/ingester_grid.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main_grid_half/rebel_best_ged_grid.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main_grid_half/rebel_days_ged_grid.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main_grid_half/rebel_deathsA_ged_grid.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main_grid_half/rebel_deathsB_ged_grid.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main_grid_half/rebel_distance_ged_grid.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main_grid_half/rebel_events_ged_grid.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main_grid_half/rebel_grids_ged_grid.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main_grid_half/rebel_transnational_ged_grid.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main_grid_half/merge_grid.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main_grid_half/rebel_adjacency_ged_grid.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main_grid_half/slag_grid.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main_grid_half/lag_grid.R', chdir = TRUE)