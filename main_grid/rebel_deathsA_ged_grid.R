#merging information to panel

load('~/Dropbox/elements/coala/rebelCast/ged_panel_grid.rda')
load('~/Dropbox/elements/coala/rebelCast/GEDEvent_v22_1_temp.RData')


ucdp_ged <- GEDEvent_v22_1[,c("priogrid_gid","date_start","deaths_a")]
	ucdp_ged$date_start <- as.Date(substr(ucdp_ged$date_start,1,10))
		ucdp_ged$date_start <- lubridate::floor_date(ucdp_ged$date_start,unit = "months")	

ucdp_deaths_a_grid <- ucdp_ged %>%
						group_by(priogrid_gid,date_start) %>%
							summarise(deaths_a=sum(deaths_a,na.rm=TRUE))
							
save(ucdp_deaths_a_grid, file='~/Dropbox/elements/coala/rebelCast/ucdp_deaths_a_grid.rda')
