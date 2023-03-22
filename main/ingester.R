#ingester.R
#pulls data from GED and creates monthly dataset


load('~/Dropbox/elements/coala/rebelCast/GEDEvent_v22_1_temp.RData')
load('~/Dropbox/elements/coala/rebelCast/ucdp-dyadic-221.RData')

#Actor data frame

head(ucdp_dyadic_221)
ucdp_dyadic <- ucdp_dyadic_221[,c("side_a","side_a_id","side_b","side_b_id","start_date")]
ucdp_dyadic <- unique(ucdp_dyadic)

ucdp_dyadic.a <- ucdp_dyadic[,c("side_a","side_a_id","start_date")]
ucdp_dyadic.b <- ucdp_dyadic[,c("side_b","side_b_id","start_date")]

names(ucdp_dyadic.a) <- c("side","side_id","start_date")
names(ucdp_dyadic.b) <- c("side","side_id","start_date")

ucdp_dyadic.a$side_id <- as.numeric(ucdp_dyadic.a$side_id)
ucdp_dyadic.b$side_id <- as.numeric(ucdp_dyadic.b$side_id)

ucdp_dyadic <- dplyr::bind_rows(ucdp_dyadic.a,ucdp_dyadic.b)
ucdp_dyadic <- unique(ucdp_dyadic)


ucdp_dyadic <- ucdp_dyadic %>%
						group_by(side_id) %>%
							mutate(min.date=min(start_date))
							
ucdp_dyadic <- ucdp_dyadic[ucdp_dyadic$min.date==ucdp_dyadic$start_date,]

length(unique(ucdp_dyadic$side_id))==dim(ucdp_dyadic)[1]


#now we need to get the min and maximum date from GED.
head(GEDEvent_v22_1)
ucdp_ged <- GEDEvent_v22_1[,c("side_a_new_id","side_a","side_b_new_id","side_b","date_start","date_end")]
	ucdp_ged$date_start <- as.Date(substr(ucdp_ged$date_start,1,10))
		ucdp_ged$date_end <- as.Date(substr(ucdp_ged$date_end,1,10))
		
ucdp_ged.a <- ucdp_ged[,c("side_a","side_a_new_id","date_start","date_end")]
ucdp_ged.b <- ucdp_ged[,c("side_b","side_b_new_id","date_start","date_end")]

names(ucdp_ged.a) <- c("side","side_id","date_start","date_end")
names(ucdp_ged.b) <- c("side","side_id","date_start","date_end")
		
ucdp_ged <- dplyr::bind_rows(ucdp_ged.a,ucdp_ged.b)
ucdp_ged <- unique(ucdp_ged)

ucdp_ged <- ucdp_ged %>%
						group_by(side_id) %>%
							mutate(min.date=min(date_start),max.date=max(date_end))
							
ucdp_ged <- ucdp_ged[ucdp_ged$min.date==ucdp_ged$date_start,]
	ucdp_ged <- ucdp_ged[,c("side","side_id","min.date","max.date")]	
		ucdp_ged <- unique(ucdp_ged)

length(unique(ucdp_ged$side_id))==dim(ucdp_ged)[1]		
		ucdp_ged$min.date <- lubridate::floor_date(ucdp_ged$min.date,unit = "months")	
		ucdp_ged$max.date <- lubridate::floor_date(ucdp_ged$max.date,unit = "months")	

#Expand the data set according to start and stop

ged_panel <- ucdp_ged %>%
				group_by(side_id) %>% 
do(data.frame(date_start = seq(from = .$min.date, to = .$max.date, by = "months"))) 

save(ged_panel,file='~/Dropbox/elements/coala/rebelCast/ged_panel.rda')
      



		




