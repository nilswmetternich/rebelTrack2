library(zoo)
library(dplyr)



load('~/Dropbox/elements/coala/multistate/data/ged50.Rdata')


#Let's focus first on state-based violence (type_of_violence==1) where the side_b_dset_id is always a non-state actor (need to make sure that these are always rebel organizations(let's assume for now >1000 <2000))

ged50 <- data.frame(ged50)
	data.all <- ged50[ged50$type_of_vi==1,which(names(ged50)%in%c("side_b_new","date_start","latitude","longitude") )]
	

#################################
#################################
# unique side_b_new
uniq.org <- unique(data.all$side_b_new)

# calculations for each organization
for(i in 1:length(uniq.org)){
	org.temp <- uniq.org[i]
		data.org <- data.all[data.all$side_b_new==org.temp,]

min.date <- min(data.org$date_start)
max.date <- max(data.org$date_start)

data.org$datum <- as.yearmon(data.org$date_start)
	data.org<- unique(data.org)


data.org <- aggregate(data.frame(data.org$latitude,data.org$longitude), by=list(data.org$side_b_new,data.org$datum),FUN=mean)
	colnames(data.org) <- c("side_b_new","datum","latitude","longitude")

data.org.temp <- data.frame(as.yearmon(seq(min.date, max.date, by = "month")),org.temp)
	names(data.org.temp) <- c("datum","side_b_new")

data.org <- merge(data.org.temp,data.org,by=c("datum","side_b_new"), all.x=TRUE, all.y=FALSE)
		#data.org <- arrange(data.org,datum)

if(i==1){
	mean.fighting <- data.org
}

if(i>1){
	mean.fighting <- rbind(mean.fighting,data.org)	
}


}

load('~/Documents/git/rebelTrack/Rcode/uniq.org.rda')


mean.fighting <- merge(mean.fighting,uniq.org,by=c("side_b_new"),all.x=TRUE)

save(mean.fighting,file="~/Documents/git/rebelTrack/Rcode/mean_fighting/mean.fighting.rda")












