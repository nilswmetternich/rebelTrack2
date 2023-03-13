#ingester.R
#pulls data from GED and creates monthly dataset


load('~/Dropbox/elements/coala/rebelCast/GEDEvent_v22_1.RData')

#Grid data frame

#now we need to get the min and maximum date from GED.
names(GEDEvent_v22_1)
ucdp_ged <- GEDEvent_v22_1[,c("priogrid_gid","date_start","date_end")]
	ucdp_ged$date_start <- as.Date(substr(ucdp_ged$date_start,1,10))
		ucdp_ged$date_end <- as.Date(substr(ucdp_ged$date_end,1,10))
		
ucdp_ged <- ucdp_ged[,c("priogrid_gid","date_start","date_end")]

ucdp_ged <- unique(ucdp_ged)

ucdp_ged <- ucdp_ged %>%
						group_by(priogrid_gid) %>%
							mutate(min.date=min(date_start),max.date=max(date_end))
							
ucdp_ged <- ucdp_ged[ucdp_ged$min.date==ucdp_ged$date_start,]
	ucdp_ged <- ucdp_ged[,c("priogrid_gid","min.date","max.date")]	
		ucdp_ged <- unique(ucdp_ged)

length(unique(ucdp_ged$priogrid_gid))==dim(ucdp_ged)[1]		
		ucdp_ged$min.date <- lubridate::floor_date(ucdp_ged$min.date,unit = "months")	
		ucdp_ged$max.date <- lubridate::floor_date(ucdp_ged$max.date,unit = "months")	

#Expand the data set according to start and stop

ged_panel_grid <- ucdp_ged %>%
				group_by(priogrid_gid) %>% 
do(data.frame(date_start = seq(from = .$min.date, to = .$max.date, by = "months"))) 

save(ged_panel_grid,file='~/Dropbox/elements/coala/rebelCast/ged_panel_grid.rda')
      



		




