#merging information to panel

load('~/Dropbox/elements/coala/rebelCast/ged_panel_grid.rda')
test.1 <- dim(ged_panel_grid)[1]

#merge rebel_best
load('~/Dropbox/elements/coala/rebelCast/ucdp_best_grid.rda')
ged_panel_grid <- left_join(ged_panel_grid,ucdp_best_grid)
ged_panel_grid$best[is.na(ged_panel_grid$best)] <- 0

#merge rebel_days
load('~/Dropbox/elements/coala/rebelCast/ucdp_days_grid.rda')
ged_panel_grid <- left_join(ged_panel_grid,ucdp_days_grid)
ged_panel_grid$days[is.na(ged_panel_grid$days)] <- 0


#merge rebel_distance
load('~/Dropbox/elements/coala/rebelCast/ucdp_distance_grid.rda')
ged_panel_grid <- left_join(ged_panel_grid,ucdp_distance_grid)

ged_panel_grid <- ged_panel_grid %>%
				group_by(priogrid_gid) %>%
					tidyr::fill(mean.bdist3)

ged_panel_grid <- ged_panel_grid %>%
				group_by(priogrid_gid) %>%
					tidyr::fill(mean.capdist)


#merge rebel_events
load('~/Dropbox/elements/coala/rebelCast/ucdp_events_grid.rda')
ged_panel_grid <- left_join(ged_panel_grid,ucdp_events_grid)
ged_panel_grid$events[is.na(ged_panel_grid$events)] <- 0


#merge rebel_grids
load('~/Dropbox/elements/coala/rebelCast/ucdp_actors_grid.rda')
ged_panel_grid <- left_join(ged_panel_grid,ucdp_actors_grid)
ged_panel_grid$actors[is.na(ged_panel_grid$actors)] <- 0

#merge rebel_transnational
load('~/Dropbox/elements/coala/rebelCast/transnational_ratio_grid.rda')
ged_panel_grid <- left_join(ged_panel_grid,transnational_ratio_grid)
ged_panel_grid$transnational_ratio[is.na(ged_panel_grid$transnational_ratio)] <- 0


test.2 <- dim(ged_panel_grid)[1]

test.1==test.2

ged_merge_grid <- ged_panel_grid

save(ged_merge_grid, file='~/Dropbox/elements/coala/rebelCast/ged_merge_grid.rda')






