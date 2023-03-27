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

source('~/Documents/git/rebelTrack2/main_half/actors.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main_half/ingester.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main_half/rebel_best_ged.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main_half/rebel_days_ged.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main_half/rebel_deathsA_ged.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main_half/rebel_deathsB_ged.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main_half/rebel_distance_ged.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main_half/rebel_events_ged.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main_half/rebel_grids_ged.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main_half/rebel_transnational_ged.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main_half/merge.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main_half/rebel_adjacency_ged.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main_half/slag.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main_half/lag.R', chdir = TRUE)