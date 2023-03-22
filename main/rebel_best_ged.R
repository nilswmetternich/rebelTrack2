#merging information to panel

load('~/Dropbox/elements/coala/rebelCast/ged_panel.rda')
load('~/Dropbox/elements/coala/rebelCast/GEDEvent_v22_1_temp.RData')


ucdp_ged <- GEDEvent_v22_1[,c("side_a_new_id","side_a","side_b_new_id","side_b","date_start","best")]
	ucdp_ged$date_start <- as.Date(substr(ucdp_ged$date_start,1,10))
		ucdp_ged$date_start <- lubridate::floor_date(ucdp_ged$date_start,unit = "months")	


ucdp_ged.a <- ucdp_ged[,c("side_a","side_a_new_id","date_start","best")]
ucdp_ged.b <- ucdp_ged[,c("side_b","side_b_new_id","date_start","best")]

names(ucdp_ged.a) <- c("side","side_id","date_start","best")
names(ucdp_ged.b) <- c("side","side_id","date_start","best")
		
ucdp_ged <- dplyr::bind_rows(ucdp_ged.a,ucdp_ged.b)


ucdp_best <- ucdp_ged %>%
						group_by(side_id,date_start) %>%
							summarise(best=sum(best,na.rm=TRUE))
							
save(ucdp_best, file='~/Dropbox/elements/coala/rebelCast/ucdp_best.rda')
