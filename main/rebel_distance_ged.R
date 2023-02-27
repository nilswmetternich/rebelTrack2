#merging information to panel

load('~/Dropbox/elements/coala/rebelCast/ged_panel.rda')
load('~/Dropbox/elements/coala/rebelCast/GEDEvent_v22_1.RData')
prio.grid <- read.csv("~/Dropbox/elements/coala/rebelCast/PRIO-GRID Yearly Variables for 2014-2014 - 2023-02-27.csv")

#for(i in 2015:2023){
#	prio.grid.n <- prio.grid[prio.grid$year==2014,]
#	prio.grid.n$year <- i
#	prio.grid <- dplyr::bind_rows(prio.grid,prio.grid.n)
#}


prio.grid <- prio.grid %>%
				group_by(gid) %>%
					summarise(mean.bdist3=mean(bdist3,na.rm=FALSE), mean.capdist=mean(capdist,na.rm=TRUE))



ucdp_ged <- GEDEvent_v22_1[,c("side_a_new_id","side_a","side_b_new_id","side_b","date_start","year","priogrid_gid")]
	ucdp_ged$date_start <- as.Date(substr(ucdp_ged$date_start,1,10))
		ucdp_ged$date_start <- lubridate::floor_date(ucdp_ged$date_start,unit = "months")	

ucdp_ged.a <- ucdp_ged[,c("side_a","side_a_new_id","date_start","year","priogrid_gid")]
ucdp_ged.b <- ucdp_ged[,c("side_b","side_b_new_id","date_start","year","priogrid_gid")]

names(ucdp_ged.a) <- c("side","side_id","date_start","year","priogrid_gid")
names(ucdp_ged.b) <- c("side","side_id","date_start","year","priogrid_gid")
		
ucdp_ged <- dplyr::bind_rows(ucdp_ged.a,ucdp_ged.b)

ucdp_ged <- left_join(ucdp_ged,prio.grid,by=c("priogrid_gid"="gid"))

ucdp_distance <- ucdp_ged %>%
						group_by(side_id,date_start) %>%
							summarise(mean.bdist3=mean(mean.bdist3,na.rm=FALSE),mean.capdist=mean(mean.capdist,na.rm=FALSE))






