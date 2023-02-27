library(zoo)
library(dplyr)



load('~/Dropbox/elements/coala/multistate/data/ged50.Rdata')


ged50 <- data.frame(ged50)
	data.all <- ged50[ged50$type_of_vi==1,which(names(ged50)%in%c("side_b_new","date_start") )]

max.date.all <- max(data.all$date_start)

#################################
#################################

uniq.org <- unique(data.all$side_b_new)


for(i in 1:length(uniq.org)){
	org.temp <- uniq.org[i]
		data.org <- data.all[data.all$side_b_new==org.temp,]

min.date <- min(data.org$date_start)
max.date <- max(data.org$date_start)

data.org$datum <- as.yearmon(data.org$date_start)


data.org.temp <- data.frame(as.yearmon(seq(min.date, max.date, by = "month")),org.temp)
	names(data.org.temp) <- c("datum","side_b_new")

data.org.temp <- data.org.temp[order(data.org.temp$datum),]

data.org.temp$duration <- 1:dim(data.org.temp)[1]	


data.org.temp$end <- 0	

data.org.temp$end <- ifelse(data.org.temp$datum==as.yearmon(max.date),1,0)	

data.org.temp$end[data.org.temp$end==1 & data.org.temp$datum>as.yearmon("2014-12-31")] <- 0

if(i==1){
	org.duration <- data.org.temp
}

if(i>1){
	org.duration <- rbind(org.duration,data.org.temp)	
}


}

load('~/Documents/git/rebelTrack/Rcode/uniq.org.rda')


org.duration <- merge(org.duration,uniq.org,by=c("side_b_new"),all.x=TRUE)

save(org.duration,file="~/Documents/git/rebelTrack/Rcode/duration/org.duration.rda")












