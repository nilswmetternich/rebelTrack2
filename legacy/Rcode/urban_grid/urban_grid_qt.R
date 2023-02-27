library(zoo)
library(dplyr)



load('~/Dropbox/elements/coala/multistate/data/ged50.Rdata')


#Let's focus first on state-based violence (type_of_violence==1) where the side_b_dset_id is always a non-state actor (need to make sure that these are always rebel organizations(let's assume for now >1000 <2000))

ged50 <- data.frame(ged50)
	data.all <- ged50[ged50$type_of_vi==1,which(names(ged50)%in%c("side_b_new","date_start","year","priogrid_g") )]
	
data.all$priogrid_g <- as.numeric(as.character(data.all$priogrid_g))

prio.grid <- read.csv("~/Dropbox/elements/coala/multistate/data/PRIO-GRID Yearly Variables for 1989-2014 - 2017-08-07_urban.csv",header=TRUE)


data.all <- merge(data.all,prio.grid,by.x=c("year","priogrid_g"),by.y=c("year","gid"),all.x=TRUE) # some grids don't match? what is this?

data.all <- data.all[,-1]



#################################
#################################

uniq.org <- unique(data.all$side_b_new)


for(i in 1:length(uniq.org)){
	org.temp <- uniq.org[i]
		data.org <- data.all[data.all$side_b_new==org.temp,]

min.date <- min(data.org$date_start)
max.date <- max(data.org$date_start)

data.org$datum <- as.yearqtr(data.org$date_start)
notwant <- which(colnames(data.org) %in% "date_start")
	data.org<- data.org[,-notwant]
		

data.org <- aggregate(data.org[,3:15], by=list(data.org$side_b_new,data.org$datum),FUN=mean,na.rm=TRUE)
	colnames(data.org)[1:2] <- c("side_b_new","datum")

data.org.temp <- data.frame(unique(c(as.yearqtr(seq(min.date, max.date, by = "quarter")),as.yearqtr(max.date))),org.temp)
	names(data.org.temp) <- c("datum","side_b_new")

data.org <- merge(data.org.temp,data.org,by=c("datum","side_b_new"), all.x=TRUE, all.y=FALSE)
		#data.org <- arrange(data.org,datum)

if(i==1){
	urban.prio <- data.org
}

if(i>1){
	urban.prio <- rbind(urban.prio,data.org)	
}



}

load('~/Documents/git/rebelTrack/Rcode/uniq.org.rda')

urban.prio <- merge(urban.prio,uniq.org,by=c("side_b_new"),all.x=TRUE)

save(urban.prio,file="~/Documents/git/rebelTrack/Rcode/urban_grid/urban.prio.qt.rda")









