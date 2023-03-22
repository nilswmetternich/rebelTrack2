#merging information to panel

load('~/Dropbox/elements/coala/rebelCast/ged_panel.rda')
load('~/Dropbox/elements/coala/rebelCast/GEDEvent_v22_1_temp.RData')


ucdp_ged <- GEDEvent_v22_1[,c("priogrid_gid","date_start")]
	ucdp_ged$date_start <- as.Date(substr(ucdp_ged$date_start,1,10))
		ucdp_ged$date_start <- lubridate::floor_date(ucdp_ged$date_start,unit = "months")	

ucdp_ged$event <- 1
		
ucdp_events_grid <- ucdp_ged %>%
						group_by(priogrid_gid,date_start) %>%
							summarise(events=sum(event,na.rm=TRUE))
							

save(ucdp_events_grid, file='~/Dropbox/elements/coala/rebelCast/ucdp_events_grid.rda')

