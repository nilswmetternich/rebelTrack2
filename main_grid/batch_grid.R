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

source('~/Documents/git/rebelTrack2/main_grid/actors_grid.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main_grid/ingester_grid.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main_grid/rebel_best_ged_grid.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main_grid/rebel_days_ged_grid.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main_grid/rebel_deathsA_ged_grid.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main_grid/rebel_deathsB_ged_grid.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main_grid/rebel_distance_ged_grid.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main_grid/rebel_events_ged_grid.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main_grid/rebel_grids_ged_grid.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main_grid/rebel_transnational_ged_grid.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main_grid/merge_grid.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main_grid/rebel_adjacency_ged_grid.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main_grid/slag_grid.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main_grid/lag_grid.R', chdir = TRUE)