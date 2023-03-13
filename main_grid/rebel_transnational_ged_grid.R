#merging information to panel

load('~/Dropbox/elements/coala/rebelCast/GEDEvent_v22_1.RData')


ucdp_ged <- GEDEvent_v22_1[,c("side_a_new_id","side_a","side_b_new_id","side_b","date_start","country_id","priogrid_gid")]
	ucdp_ged$date_start <- as.Date(substr(ucdp_ged$date_start,1,10))
		ucdp_ged$date_start <- lubridate::floor_date(ucdp_ged$date_start,unit = "months")	

ucdp_ged.a <- ucdp_ged[,c("side_a","side_a_new_id","date_start","country_id","priogrid_gid")]
ucdp_ged.b <- ucdp_ged[,c("side_b","side_b_new_id","date_start","country_id","priogrid_gid")]

names(ucdp_ged.a) <- c("side","side_id","date_start","country_id","priogrid_gid")
names(ucdp_ged.b) <- c("side","side_id","date_start","country_id","priogrid_gid")
		
ucdp_ged <- dplyr::bind_rows(ucdp_ged.a,ucdp_ged.b)

ucdp_help <- unique(ucdp_ged[,c("side_id","date_start","priogrid_gid")])

ucdp_ged$event <- 1

ucdp_events <- ucdp_ged %>%
						group_by(side_id,date_start,country_id) %>%
							summarise(events=sum(event,na.rm=TRUE))

transnational_ratio <- ucdp_events %>%
						group_by(side_id,date_start) %>%
							summarise(transnational_ratio=1-(max(events,na.rm=TRUE)/sum(events,na.rm=TRUE)))

							
transnational_ratio_grid <- left_join(ucdp_help,transnational_ratio)

transnational_ratio_grid <- transnational_ratio_grid %>%
						group_by(priogrid_gid,date_start) %>%
							summarise(transnational_ratio=mean(transnational_ratio,na.rm=TRUE))
							
							

save(transnational_ratio, file='~/Dropbox/elements/coala/rebelCast/transnational_ratio.rda')


