#laging information to panel


load('~/Dropbox/elements/coala/rebelCast/ged_merge_sp_grid.rda')


ged_merge_sp_grid <- ged_merge_sp_grid %>%
	group_by(priogrid_gid) %>%
		mutate(best_l1 = lag(best, n=1, order_by = date_start),
			best_l2 = lag(best, n=2, order_by = date_start),
			best_l3 = lag(best, n=3, order_by = date_start),
			best_l4 = lag(best, n=4, order_by = date_start),
			best_l5 = lag(best, n=5, order_by = date_start),
			best_l6 = lag(best, n=6, order_by = date_start),
			best_l7 = lag(best, n=7, order_by = date_start),
			best_l8 = lag(best, n=8, order_by = date_start),
			best_l9 = lag(best, n=9, order_by = date_start),
			best_l10 = lag(best, n=10, order_by = date_start),
			best_l11 = lag(best, n=11, order_by = date_start),
			best_l12 = lag(best, n=12, order_by = date_start))

ged_merge_sp_grid <- ged_merge_sp_grid %>%
	group_by(priogrid_gid) %>%
		mutate(days_l1 = lag(days, n=1, order_by = date_start),
			days_l2 = lag(days, n=2, order_by = date_start),
			days_l3 = lag(days, n=3, order_by = date_start),
			days_l4 = lag(days, n=4, order_by = date_start),
			days_l5 = lag(days, n=5, order_by = date_start),
			days_l6 = lag(days, n=6, order_by = date_start),
			days_l7 = lag(days, n=7, order_by = date_start),
			days_l8 = lag(days, n=8, order_by = date_start),
			days_l9 = lag(days, n=9, order_by = date_start),
			days_l10 = lag(days, n=10, order_by = date_start),
			days_l11 = lag(days, n=11, order_by = date_start),
			days_l12 = lag(days, n=12, order_by = date_start))
			
ged_merge_sp_grid <- ged_merge_sp_grid %>%
	group_by(priogrid_gid) %>%
		mutate(deaths_a_l1 = lag(deaths_a, n=1, order_by = date_start),
			deaths_a_l2 = lag(deaths_a, n=2, order_by = date_start),
			deaths_a_l3 = lag(deaths_a, n=3, order_by = date_start),
			deaths_a_l4 = lag(deaths_a, n=4, order_by = date_start),
			deaths_a_l5 = lag(deaths_a, n=5, order_by = date_start),
			deaths_a_l6 = lag(deaths_a, n=6, order_by = date_start),
			deaths_a_l7 = lag(deaths_a, n=7, order_by = date_start),
			deaths_a_l8 = lag(deaths_a, n=8, order_by = date_start),
			deaths_a_l9 = lag(deaths_a, n=9, order_by = date_start),
			deaths_a_l10 = lag(deaths_a, n=10, order_by = date_start),
			deaths_a_l11 = lag(deaths_a, n=11, order_by = date_start),
			deaths_a_l12 = lag(deaths_a, n=12, order_by = date_start))

ged_merge_sp_grid <- ged_merge_sp_grid %>%
	group_by(priogrid_gid) %>%
		mutate(deaths_b_l1 = lag(deaths_b, n=1, order_by = date_start),
			deaths_b_l2 = lag(deaths_b, n=2, order_by = date_start),
			deaths_b_l3 = lag(deaths_b, n=3, order_by = date_start),
			deaths_b_l4 = lag(deaths_b, n=4, order_by = date_start),
			deaths_b_l5 = lag(deaths_b, n=5, order_by = date_start),
			deaths_b_l6 = lag(deaths_b, n=6, order_by = date_start),
			deaths_b_l7 = lag(deaths_b, n=7, order_by = date_start),
			deaths_b_l8 = lag(deaths_b, n=8, order_by = date_start),
			deaths_b_l9 = lag(deaths_b, n=9, order_by = date_start),
			deaths_b_l10 = lag(deaths_b, n=10, order_by = date_start),
			deaths_b_l11 = lag(deaths_b, n=11, order_by = date_start),
			deaths_b_l12 = lag(deaths_b, n=12, order_by = date_start))


ged_merge_sp_grid <- ged_merge_sp_grid %>%
	group_by(priogrid_gid) %>%
		mutate(mean.bdist3_l1 = lag(mean.bdist3, n=1, order_by = date_start),
			mean.bdist3_l2 = lag(mean.bdist3, n=2, order_by = date_start),
			mean.bdist3_l3 = lag(mean.bdist3, n=3, order_by = date_start),
			mean.bdist3_l4 = lag(mean.bdist3, n=4, order_by = date_start),
			mean.bdist3_l5 = lag(mean.bdist3, n=5, order_by = date_start),
			mean.bdist3_l6 = lag(mean.bdist3, n=6, order_by = date_start),
			mean.bdist3_l7 = lag(mean.bdist3, n=7, order_by = date_start),
			mean.bdist3_l8 = lag(mean.bdist3, n=8, order_by = date_start),
			mean.bdist3_l9 = lag(mean.bdist3, n=9, order_by = date_start),
			mean.bdist3_l10 = lag(mean.bdist3, n=10, order_by = date_start),
			mean.bdist3_l11 = lag(mean.bdist3, n=11, order_by = date_start),
			mean.bdist3_l12 = lag(mean.bdist3, n=12, order_by = date_start))
			
ged_merge_sp_grid <- ged_merge_sp_grid %>%
	group_by(priogrid_gid) %>%
		mutate(mean.capdist_l1 = lag(mean.capdist, n=1, order_by = date_start),
			mean.capdist_l2 = lag(mean.capdist, n=2, order_by = date_start),
			mean.capdist_l3 = lag(mean.capdist, n=3, order_by = date_start),
			mean.capdist_l4 = lag(mean.capdist, n=4, order_by = date_start),
			mean.capdist_l5 = lag(mean.capdist, n=5, order_by = date_start),
			mean.capdist_l6 = lag(mean.capdist, n=6, order_by = date_start),
			mean.capdist_l7 = lag(mean.capdist, n=7, order_by = date_start),
			mean.capdist_l8 = lag(mean.capdist, n=8, order_by = date_start),
			mean.capdist_l9 = lag(mean.capdist, n=9, order_by = date_start),
			mean.capdist_l10 = lag(mean.capdist, n=10, order_by = date_start),
			mean.capdist_l11 = lag(mean.capdist, n=11, order_by = date_start),
			mean.capdist_l12 = lag(mean.capdist, n=12, order_by = date_start))
			
ged_merge_sp_grid <- ged_merge_sp_grid %>%
	group_by(priogrid_gid) %>%
		mutate(events_l1 = lag(events, n=1, order_by = date_start),
			events_l2 = lag(events, n=2, order_by = date_start),
			events_l3 = lag(events, n=3, order_by = date_start),
			events_l4 = lag(events, n=4, order_by = date_start),
			events_l5 = lag(events, n=5, order_by = date_start),
			events_l6 = lag(events, n=6, order_by = date_start),
			events_l7 = lag(events, n=7, order_by = date_start),
			events_l8 = lag(events, n=8, order_by = date_start),
			events_l9 = lag(events, n=9, order_by = date_start),
			events_l10 = lag(events, n=10, order_by = date_start),
			events_l11 = lag(events, n=11, order_by = date_start),
			events_l12 = lag(events, n=12, order_by = date_start))
			
ged_merge_sp_grid <- ged_merge_sp_grid %>%
	group_by(priogrid_gid) %>%
		mutate(grids_l1 = lag(grids, n=1, order_by = date_start),
			grids_l2 = lag(grids, n=2, order_by = date_start),
			grids_l3 = lag(grids, n=3, order_by = date_start),
			grids_l4 = lag(grids, n=4, order_by = date_start),
			grids_l5 = lag(grids, n=5, order_by = date_start),
			grids_l6 = lag(grids, n=6, order_by = date_start),
			grids_l7 = lag(grids, n=7, order_by = date_start),
			grids_l8 = lag(grids, n=8, order_by = date_start),
			grids_l9 = lag(grids, n=9, order_by = date_start),
			grids_l10 = lag(grids, n=10, order_by = date_start),
			grids_l11 = lag(grids, n=11, order_by = date_start),
			grids_l12 = lag(grids, n=12, order_by = date_start))
			
			

ged_merge_sp_grid <- ged_merge_sp_grid %>%
	group_by(priogrid_gid) %>%
		mutate(best.sp_l1 = lag(best.sp, n=1, order_by = date_start),
			best.sp_l2 = lag(best.sp, n=2, order_by = date_start),
			best.sp_l3 = lag(best.sp, n=3, order_by = date_start),
			best.sp_l4 = lag(best.sp, n=4, order_by = date_start),
			best.sp_l5 = lag(best.sp, n=5, order_by = date_start),
			best.sp_l6 = lag(best.sp, n=6, order_by = date_start),
			best.sp_l7 = lag(best.sp, n=7, order_by = date_start),
			best.sp_l8 = lag(best.sp, n=8, order_by = date_start),
			best.sp_l9 = lag(best.sp, n=9, order_by = date_start),
			best.sp_l10 = lag(best.sp, n=10, order_by = date_start),
			best.sp_l11 = lag(best.sp, n=11, order_by = date_start),
			best.sp_l12 = lag(best.sp, n=12, order_by = date_start))

ged_merge_sp_grid <- ged_merge_sp_grid %>%
	group_by(priogrid_gid) %>%
		mutate(days.sp_l1 = lag(days.sp, n=1, order_by = date_start),
			days.sp_l2 = lag(days.sp, n=2, order_by = date_start),
			days.sp_l3 = lag(days.sp, n=3, order_by = date_start),
			days.sp_l4 = lag(days.sp, n=4, order_by = date_start),
			days.sp_l5 = lag(days.sp, n=5, order_by = date_start),
			days.sp_l6 = lag(days.sp, n=6, order_by = date_start),
			days.sp_l7 = lag(days.sp, n=7, order_by = date_start),
			days.sp_l8 = lag(days.sp, n=8, order_by = date_start),
			days.sp_l9 = lag(days.sp, n=9, order_by = date_start),
			days.sp_l10 = lag(days.sp, n=10, order_by = date_start),
			days.sp_l11 = lag(days.sp, n=11, order_by = date_start),
			days.sp_l12 = lag(days.sp, n=12, order_by = date_start))
			
ged_merge_sp_grid <- ged_merge_sp_grid %>%
	group_by(priogrid_gid) %>%
		mutate(deaths_a.sp_l1 = lag(deaths_a.sp, n=1, order_by = date_start),
			deaths_a.sp_l2 = lag(deaths_a.sp, n=2, order_by = date_start),
			deaths_a.sp_l3 = lag(deaths_a.sp, n=3, order_by = date_start),
			deaths_a.sp_l4 = lag(deaths_a.sp, n=4, order_by = date_start),
			deaths_a.sp_l5 = lag(deaths_a.sp, n=5, order_by = date_start),
			deaths_a.sp_l6 = lag(deaths_a.sp, n=6, order_by = date_start),
			deaths_a.sp_l7 = lag(deaths_a.sp, n=7, order_by = date_start),
			deaths_a.sp_l8 = lag(deaths_a.sp, n=8, order_by = date_start),
			deaths_a.sp_l9 = lag(deaths_a.sp, n=9, order_by = date_start),
			deaths_a.sp_l10 = lag(deaths_a.sp, n=10, order_by = date_start),
			deaths_a.sp_l11 = lag(deaths_a.sp, n=11, order_by = date_start),
			deaths_a.sp_l12 = lag(deaths_a.sp, n=12, order_by = date_start))
			
ged_merge_sp_grid <- ged_merge_sp_grid %>%
	group_by(priogrid_gid) %>%
		mutate(deaths_b.sp_l1 = lag(deaths_b.sp, n=1, order_by = date_start),
			deaths_b.sp_l2 = lag(deaths_b.sp, n=2, order_by = date_start),
			deaths_b.sp_l3 = lag(deaths_b.sp, n=3, order_by = date_start),
			deaths_b.sp_l4 = lag(deaths_b.sp, n=4, order_by = date_start),
			deaths_b.sp_l5 = lag(deaths_b.sp, n=5, order_by = date_start),
			deaths_b.sp_l6 = lag(deaths_b.sp, n=6, order_by = date_start),
			deaths_b.sp_l7 = lag(deaths_b.sp, n=7, order_by = date_start),
			deaths_b.sp_l8 = lag(deaths_b.sp, n=8, order_by = date_start),
			deaths_b.sp_l9 = lag(deaths_b.sp, n=9, order_by = date_start),
			deaths_b.sp_l10 = lag(deaths_b.sp, n=10, order_by = date_start),
			deaths_b.sp_l11 = lag(deaths_b.sp, n=11, order_by = date_start),
			deaths_b.sp_l12 = lag(deaths_b.sp, n=12, order_by = date_start))

ged_merge_sp_grid <- ged_merge_sp_grid %>%
	group_by(priogrid_gid) %>%
		mutate(mean.bdist3.sp_l1 = lag(mean.bdist3.sp, n=1, order_by = date_start),
			mean.bdist3.sp_l2 = lag(mean.bdist3.sp, n=2, order_by = date_start),
			mean.bdist3.sp_l3 = lag(mean.bdist3.sp, n=3, order_by = date_start),
			mean.bdist3.sp_l4 = lag(mean.bdist3.sp, n=4, order_by = date_start),
			mean.bdist3.sp_l5 = lag(mean.bdist3.sp, n=5, order_by = date_start),
			mean.bdist3.sp_l6 = lag(mean.bdist3.sp, n=6, order_by = date_start),
			mean.bdist3.sp_l7 = lag(mean.bdist3.sp, n=7, order_by = date_start),
			mean.bdist3.sp_l8 = lag(mean.bdist3.sp, n=8, order_by = date_start),
			mean.bdist3.sp_l9 = lag(mean.bdist3.sp, n=9, order_by = date_start),
			mean.bdist3.sp_l10 = lag(mean.bdist3.sp, n=10, order_by = date_start),
			mean.bdist3.sp_l11 = lag(mean.bdist3.sp, n=11, order_by = date_start),
			mean.bdist3.sp_l12 = lag(mean.bdist3.sp, n=12, order_by = date_start))
			
ged_merge_sp_grid <- ged_merge_sp_grid %>%
	group_by(priogrid_gid) %>%
		mutate(mean.capdist.sp_l1 = lag(mean.capdist.sp, n=1, order_by = date_start),
			mean.capdist.sp_l2 = lag(mean.capdist.sp, n=2, order_by = date_start),
			mean.capdist.sp_l3 = lag(mean.capdist.sp, n=3, order_by = date_start),
			mean.capdist.sp_l4 = lag(mean.capdist.sp, n=4, order_by = date_start),
			mean.capdist.sp_l5 = lag(mean.capdist.sp, n=5, order_by = date_start),
			mean.capdist.sp_l6 = lag(mean.capdist.sp, n=6, order_by = date_start),
			mean.capdist.sp_l7 = lag(mean.capdist.sp, n=7, order_by = date_start),
			mean.capdist.sp_l8 = lag(mean.capdist.sp, n=8, order_by = date_start),
			mean.capdist.sp_l9 = lag(mean.capdist.sp, n=9, order_by = date_start),
			mean.capdist.sp_l10 = lag(mean.capdist.sp, n=10, order_by = date_start),
			mean.capdist.sp_l11 = lag(mean.capdist.sp, n=11, order_by = date_start),
			mean.capdist.sp_l12 = lag(mean.capdist.sp, n=12, order_by = date_start))
			
ged_merge_sp_grid <- ged_merge_sp_grid %>%
	group_by(priogrid_gid) %>%
		mutate(events.sp_l1 = lag(events.sp, n=1, order_by = date_start),
			events.sp_l2 = lag(events.sp, n=2, order_by = date_start),
			events.sp_l3 = lag(events.sp, n=3, order_by = date_start),
			events.sp_l4 = lag(events.sp, n=4, order_by = date_start),
			events.sp_l5 = lag(events.sp, n=5, order_by = date_start),
			events.sp_l6 = lag(events.sp, n=6, order_by = date_start),
			events.sp_l7 = lag(events.sp, n=7, order_by = date_start),
			events.sp_l8 = lag(events.sp, n=8, order_by = date_start),
			events.sp_l9 = lag(events.sp, n=9, order_by = date_start),
			events.sp_l10 = lag(events.sp, n=10, order_by = date_start),
			events.sp_l11 = lag(events.sp, n=11, order_by = date_start),
			events.sp_l12 = lag(events.sp, n=12, order_by = date_start))
			
ged_merge_sp_grid <- ged_merge_sp_grid %>%
	group_by(priogrid_gid) %>%
		mutate(actors.sp_l1 = lag(actors.sp, n=1, order_by = date_start),
			actors.sp_l2 = lag(actors.sp, n=2, order_by = date_start),
			actors.sp_l3 = lag(actors.sp, n=3, order_by = date_start),
			actors.sp_l4 = lag(actors.sp, n=4, order_by = date_start),
			actors.sp_l5 = lag(actors.sp, n=5, order_by = date_start),
			actors.sp_l6 = lag(actors.sp, n=6, order_by = date_start),
			actors.sp_l7 = lag(actors.sp, n=7, order_by = date_start),
			actors.sp_l8 = lag(actors.sp, n=8, order_by = date_start),
			actors.sp_l9 = lag(actors.sp, n=9, order_by = date_start),
			actors.sp_l10 = lag(actors.sp, n=10, order_by = date_start),
			actors.sp_l11 = lag(actors.sp, n=11, order_by = date_start),
			actors.sp_l12 = lag(actors.sp, n=12, order_by = date_start))

ged_final_grid <- ged_merge_sp_grid
save(ged_final_grid,file='~/Dropbox/elements/coala/rebelCast/ged_final_grid.rda')



