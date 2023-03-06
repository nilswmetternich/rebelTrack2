#laging information to panel


load('~/Dropbox/elements/coala/rebelCast/ged_merge.rda')


ged_merge <- ged_merge %>%
	group_by(side_id) %>%
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

ged_merge <- ged_merge %>%
	group_by(side_id) %>%
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

arrange(right, year)




