#merging information to panel

load('~/Dropbox/elements/coala/rebelCast/GEDEvent_v22_1_temp.RData')


ucdp_ged <- GEDEvent_v22_1[,c("priogrid_gid","date_start","best")]
	ucdp_ged$date_start <- as.Date(substr(ucdp_ged$date_start,1,10))
		ucdp_ged$date_start <- lubridate::floor_date(ucdp_ged$date_start,unit = "halfyear")	

ucdp_best_grid <- ucdp_ged %>%
						group_by(priogrid_gid,date_start) %>%
							summarise(best=sum(best,na.rm=TRUE))
							
save(ucdp_best_grid, file='~/Dropbox/elements/coala/rebelCast/ucdp_best_grid_halfyear.rda')
