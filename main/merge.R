#merging information to panel

load('~/Dropbox/elements/coala/rebelCast/ged_panel.rda')
test.1 <- dim(ged_panel)[1]

#merge rebel_best
load('~/Dropbox/elements/coala/rebelCast/ucdp_best.rda')
ged_panel <- left_join(ged_panel,ucdp_best)
ged_panel$best[is.na(ged_panel$best)] <- 0

#merge rebel_days
load('~/Dropbox/elements/coala/rebelCast/ucdp_days.rda')
ged_panel <- left_join(ged_panel,ucdp_days)
ged_panel$days[is.na(ged_panel$days)] <- 0

#merge deaths_a
load('~/Dropbox/elements/coala/rebelCast/ucdp_deaths_a.rda')
ged_panel <- left_join(ged_panel,ucdp_deaths_a)
ged_panel$deaths_a[is.na(ged_panel$deaths_a)] <- 0

#merge deaths_b
load('~/Dropbox/elements/coala/rebelCast/ucdp_deaths_b.rda')
ged_panel <- left_join(ged_panel,ucdp_deaths_b)
ged_panel$deaths_b[is.na(ged_panel$deaths_b)] <- 0

#merge rebel_distance
load('~/Dropbox/elements/coala/rebelCast/ucdp_distance.rda')
ged_panel <- left_join(ged_panel,ucdp_distance)

ged_panel <- ged_panel %>%
				group_by(side_id) %>%
					tidyr::fill(mean.bdist3)

ged_panel <- ged_panel %>%
				group_by(side_id) %>%
					tidyr::fill(mean.capdist)


#merge rebel_events
load('~/Dropbox/elements/coala/rebelCast/ucdp_events.rda')
ged_panel <- left_join(ged_panel,ucdp_events)
ged_panel$events[is.na(ged_panel$events)] <- 0


#merge rebel_grids
load('~/Dropbox/elements/coala/rebelCast/ucdp_grids.rda')
ged_panel <- left_join(ged_panel,ucdp_grids)
ged_panel$grids[is.na(ged_panel$grids)] <- 0

#merge rebel_transnational
load('~/Dropbox/elements/coala/rebelCast/transnational_ratio.rda')
ged_panel <- left_join(ged_panel,transnational_ratio)
ged_panel$transnational_ratio[is.na(ged_panel$transnational_ratio)] <- 0


test.2 <- dim(ged_panel)[1]

test.1==test.2

ged_merge <- ged_panel

save(ged_merge, file='~/Dropbox/elements/coala/rebelCast/ged_merge.rda')






