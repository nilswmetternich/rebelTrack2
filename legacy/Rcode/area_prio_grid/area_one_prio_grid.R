library(zoo)
library(dplyr)



load('~/Dropbox/elements/coala/multistate/data/ged50.Rdata')


#Let's focus first on state-based violence (type_of_violence==1) where the side_b_dset_id is always a non-state actor (need to make sure that these are always rebel organizations(let's assume for now >1000 <2000))

ged50 <- data.frame(ged50)
	data.all <- ged50[ged50$type_of_vi==3,which(names(ged50)%in%c("side_a_new","date_start","priogrid_g") )]
	
data.all$priogrid_g <- as.numeric(as.character(data.all$priogrid_g))

#################################
#################################

uniq.org <- unique(data.all$side_a_new)


for(i in 1:length(uniq.org)){
	org.temp <- uniq.org[i]
		data.org <- data.all[data.all$side_a_new==org.temp,]

min.date <- min(data.org$date_start)
max.date <- max(data.org$date_start)

data.org$datum <- as.yearmon(data.org$date_start)
	data.org<- unique(data.org)
		data.org$active <- 1

data.org <- aggregate(data.org$active, by=list(data.org$side_a_new,data.org$datum),FUN=sum)
	colnames(data.org) <- c("side_a_new","datum","prio.grids.count")

data.org.temp <- data.frame(as.yearmon(seq(min.date, max.date, by = "month")),org.temp)
	names(data.org.temp) <- c("datum","side_a_new")

data.org <- merge(data.org.temp,data.org,by=c("datum","side_a_new"), all.x=TRUE, all.y=FALSE)
	data.org$prio.grids.count[is.na(data.org$prio.grids.count)==TRUE] <- 0
		#data.org <- arrange(data.org,datum)

if(i==1){
	prio.grids.count <- data.org
}

if(i>1){
	prio.grids.count <- rbind(prio.grids.count,data.org)	
}


}

load('~/Documents/git/rebelTrack/Rcode/uniq.org.rda')


prio.grids.count.one <- merge(prio.grids.count,uniq.org,by.x=c("side_a_new"),by.y=c("side_b_new"),all.x=TRUE)

save(prio.grids.count,file="~/Documents/git/rebelTrack/Rcode/area_prio_grid/prio.grids.count.rda")


# pdf(file="area_grid.pdf",height=5,width=5*1.65)
# plot(prio.grids.count$datum[prio.grids.count$side_a_new==327],prio.grids.count$prio.grids.count[prio.grids.count$side_a_new==327],type="l",axes=F,ann=F)
# axis(1)
# axis(2,las=T)
# title(main="side_a_new=327",xlab="Months",ylab="PRIO grids affected")
# dev.off()










