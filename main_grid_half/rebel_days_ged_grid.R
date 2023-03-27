#merging information to panel

load('~/Dropbox/elements/coala/rebelCast/GEDEvent_v22_1_temp.RData')


ucdp_ged <- GEDEvent_v22_1[,c("priogrid_gid","date_start")]
	ucdp_ged$date_start <- as.Date(substr(ucdp_ged$date_start,1,10))
	
ucdp_ged$days <- 1

ucdp_ged <- unique(ucdp_ged)
	
ucdp_ged$date_start <- lubridate::floor_date(ucdp_ged$date_start,unit = "halfyear")	

ucdp_days_grid <- ucdp_ged %>%
						group_by(priogrid_gid,date_start) %>%
							summarise(days=sum(days,na.rm=TRUE))
							

save(ucdp_days_grid, file='~/Dropbox/elements/coala/rebelCast/ucdp_days_grid_halfyear.rda')

