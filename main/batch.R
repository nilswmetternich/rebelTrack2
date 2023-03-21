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

source('~/Documents/git/rebelTrack2/main/ingester.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main/rebel_best_ged.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main/rebel_days_ged.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main/rebel_deathsA_ged.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main/rebel_deathsB_ged.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main/rebel_distance_ged.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main/rebel_events_ged.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main/rebel_grids_ged.R', chdir = TRUE)
source('~/Documents/git/rebelTrack2/main/rebel_transnational_ged.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main/merge.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main/rebel_adjacency_ged.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main/slag.R', chdir = TRUE)

source('~/Documents/git/rebelTrack2/main/lag.R', chdir = TRUE)