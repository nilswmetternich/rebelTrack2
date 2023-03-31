#merging information to panel


load('~/Dropbox/elements/coala/rebelCast/GEDEvent_v22_1_temp.RData')
prio.grid <- read.csv("~/Dropbox/elements/coala/rebelCast/PRIO-GRID Yearly Variables for 2014-2014 - 2023-02-27.csv")

#for(i in 2015:2023){
#	prio.grid.n <- prio.grid[prio.grid$year==2014,]
#	prio.grid.n$year <- i
#	prio.grid <- dplyr::bind_rows(prio.grid,prio.grid.n)
#}


prio.grid <- prio.grid %>%
				group_by(gid) %>%
					summarise(mean.bdist3=mean(bdist3,na.rm=TRUE), mean.capdist=mean(capdist,na.rm=TRUE))



ucdp_ged <- GEDEvent_v22_1[,c("side_a_new_id","side_a","side_b_new_id","side_b","date_start","year","priogrid_gid")]
	ucdp_ged$date_start <- as.Date(substr(ucdp_ged$date_start,1,10))
		ucdp_ged$date_start <- lubridate::floor_date(ucdp_ged$date_start,unit = "halfyear")	

ucdp_ged.a <- ucdp_ged[,c("side_a","side_a_new_id","date_start","year","priogrid_gid")]
ucdp_ged.b <- ucdp_ged[,c("side_b","side_b_new_id","date_start","year","priogrid_gid")]

names(ucdp_ged.a) <- c("side","side_id","date_start","year","priogrid_gid")
names(ucdp_ged.b) <- c("side","side_id","date_start","year","priogrid_gid")
		
ucdp_ged <- dplyr::bind_rows(ucdp_ged.a,ucdp_ged.b)

ucdp_ged <- left_join(ucdp_ged,prio.grid,by=c("priogrid_gid"="gid"))

missing.values.1 <- which(is.na(ucdp_ged$mean.bdist3))
missing.values.2 <- which(is.na(ucdp_ged$mean.capdist))

missing.values.1==missing.values.2

for(jj in 1:length(missing.values.1)){
grid.na <- ucdp_ged$priogrid_gid[missing.values.1[jj]]
	grid.fill <- c(grid.na-1,grid.na+1,grid.na-2,grid.na+2,grid.na-3,grid.na+3,grid.na-720,grid.na+720,grid.na-1440,grid.na+1440,grid.na-2160,grid.na+2160)
	 ucdp_ged$mean.bdist3[missing.values.1[jj]] <- mean(ucdp_ged$mean.bdist3[which(ucdp_ged$priogrid_gid %in% grid.fill)],na.rm=TRUE)
	 	ucdp_ged$mean.capdist[missing.values.1[jj]] <- mean(ucdp_ged$mean.bdist3[which(ucdp_ged$priogrid_gid %in% grid.fill)],na.rm=TRUE)
}


ucdp_distance <- ucdp_ged %>%
						group_by(side_id,date_start) %>%
							summarise(mean.bdist3=mean(mean.bdist3,na.rm=TRUE),mean.capdist=mean(mean.capdist,na.rm=TRUE))
							
							
				
							

save(ucdp_distance, file='~/Dropbox/elements/coala/rebelCast/ucdp_distance_halfyear.rda')





