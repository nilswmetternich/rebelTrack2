#merging information to panel

load('~/Dropbox/elements/coala/rebelCast/ged_panel.rda')
load('~/Dropbox/elements/coala/rebelCast/GEDEvent_v22_1.RData')


ucdp_ged <- GEDEvent_v22_1[,c("side_a_new_id","side_a","side_b_new_id","side_b","date_start","best")]
	ucdp_ged$date_start <- as.Date(substr(ucdp_ged$date_start,1,10))
		ucdp_ged$date_start <- lubridate::floor_date(ucdp_ged$date_start,unit = "months")	






ucdp_ged.a <- ucdp_ged[,c("side_a","side_a_new_id","date_start","date_end")]
ucdp_ged.b <- ucdp_ged[,c("side_b","side_b_new_id","date_start","date_end")]



#Best estimate

#Events

#Event-days

#Distance to border

#Distance to capital

#Transnational