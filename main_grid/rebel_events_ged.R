#merging information to panel

load('~/Dropbox/elements/coala/rebelCast/ged_panel.rda')
load('~/Dropbox/elements/coala/rebelCast/GEDEvent_v22_1.RData')


ucdp_ged <- GEDEvent_v22_1[,c("side_a_new_id","side_a","side_b_new_id","side_b","date_start")]
	ucdp_ged$date_start <- as.Date(substr(ucdp_ged$date_start,1,10))
		ucdp_ged$date_start <- lubridate::floor_date(ucdp_ged$date_start,unit = "months")	

ucdp_ged$event <- 1

ucdp_ged.a <- ucdp_ged[,c("side_a","side_a_new_id","date_start","event")]
ucdp_ged.b <- ucdp_ged[,c("side_b","side_b_new_id","date_start","event")]

names(ucdp_ged.a) <- c("side","side_id","date_start","event")
names(ucdp_ged.b) <- c("side","side_id","date_start","event")
		
ucdp_ged <- dplyr::bind_rows(ucdp_ged.a,ucdp_ged.b)


ucdp_events <- ucdp_ged %>%
						group_by(side_id,date_start) %>%
							summarise(events=sum(event,na.rm=TRUE))
							

save(ucdp_events, file='~/Dropbox/elements/coala/rebelCast/ucdp_events.rda')

