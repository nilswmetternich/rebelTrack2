library(zoo)
library(dplyr)



load('~/Dropbox/elements/coala/multistate/data/ged50.Rdata')


ged50 <- data.frame(ged50)
	data.all <- ged50[ged50$type_of_vi==1,which(names(ged50)%in%c("side_b_new","date_start","deaths_a","deaths_b") )]



#################################
#################################

uniq.org <- unique(data.all$side_b_new)


for(i in 1:length(uniq.org)){
	org.temp <- uniq.org[i]
		data.org <- data.all[data.all$side_b_new==org.temp,]

min.date <- min(data.org$date_start)
max.date <- max(data.org$date_start)

data.org$datum <- as.yearqtr(data.org$date_start)


data.org <- aggregate(cbind(data.org$deaths_a,data.org$deaths_b), by=list(data.org$side_b_new,data.org$datum),FUN=sum)
	colnames(data.org) <- c("side_b_new","datum","deaths_a","deaths_b")

data.org.temp <- data.frame(unique(c(as.yearqtr(seq(min.date, max.date, by = "quarter")),as.yearqtr(max.date))),org.temp)
	names(data.org.temp) <- c("datum","side_b_new")

data.org <- merge(data.org.temp,data.org,by=c("datum","side_b_new"), all.x=TRUE, all.y=FALSE)
	data.org$deaths_a[is.na(data.org$deaths_a)==TRUE] <- 0
	data.org$deaths_b[is.na(data.org$deaths_b)==TRUE] <- 0

		data.org <- arrange(data.org,datum)

if(i==1){
	battle.deaths <- data.org
}

if(i>1){
	battle.deaths <- rbind(battle.deaths,data.org)	
}


}

load('~/Documents/git/rebelTrack/Rcode/uniq.org.rda')


battle.deaths <- merge(battle.deaths,uniq.org,by=c("side_b_new"),all.x=TRUE)

save(battle.deaths,file="~/Documents/git/rebelTrack/Rcode/battle_deaths/battle.deaths.qt.rda")


# pdf(file="battle_deaths.pdf",height=5,width=5*1.65)
# plot(battle.deaths$datum[battle.deaths$side_b_new==327],battle.deaths$deaths_a[battle.deaths$side_b_new==327],type="l",axes=F,ann=F)
# lines(battle.deaths$datum[battle.deaths$side_b_new==327],battle.deaths$deaths_b[battle.deaths$side_b_new==327],col="red")
# axis(1)
# axis(2,las=T)
# title(main="side_b_new=327",xlab="Months",ylab="battle")
# dev.off()










