library(zoo)
library(dplyr)

#calculates percentage of events in and outside main country

#calculates number of countries rebels are active in

load('~/Dropbox/elements/coala/multistate/data/ged50.Rdata')


#Let's focus first on state-based violence (type_of_violence==1) where the side_b_dset_id is always a non-state actor (need to make sure that these are always rebel organizations(let's assume for now >1000 <2000))

ged50 <- data.frame(ged50)
	data.all <- ged50[ged50$type_of_vi==1,which(names(ged50)%in%c("side_b_new","date_start","year","priogrid_g") )]

data.all$priogrid_g <- as.numeric(as.character(data.all$priogrid_g))


prio.grid <- read.csv("~/Dropbox/elements/coala/multistate/data/PRIO-GRID Yearly Variables for 1989-2014 - 2017-08-07.csv",header=TRUE)

data.all$year[data.all$year>2014] <- 2014 #this is a fix because prio grid only goes to 2014

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
notwant <- which(colnames(data.org) %in% c("date_start","priogrid_g"))
	data.org<- data.org[,-notwant]

data.org$counter <- 1 	

data.org <- aggregate(data.org$counter, by=list(data.org$side_b_new,data.org$datum,data.org$gwno),FUN=sum,na.rm=TRUE)
	colnames(data.org)[1:4] <- c("side_b_new","datum","gwno","counter")
	
countries.active <- unique(data.org$gwno)

for(jj in 1:length(countries.active)){
	
	if(jj==1){
		temp.data <- data.org[data.org$gwno==countries.active[jj],]
	}
	if(jj>1){
		temp.data <- merge(temp.data,data.org[data.org$gwno==countries.active[jj],],by=c("side_b_new","datum"),all = TRUE, all.x = TRUE, all.y = TRUE,suffixes = c(paste(jj,".x",sep=""),paste(jj,".y",sep="")))
		}
	
}
	
	
if(length(countries.active)>1){
temp.data$gwno.count <- apply(temp.data[,grep("^[c]", names(temp.data), value=TRUE)],1,function(x) length(is.na(x)[is.na(x)==FALSE]))
	
temp.data$gwno.ratio <- apply(temp.data[,grep("^[c]", names(temp.data), value=TRUE)],1,function(x) max(x,na.rm=TRUE)/sum(x,na.rm=TRUE))
}

if(length(countries.active)==1){
temp.data$gwno.count <- 1
	
temp.data$gwno.ratio <- 1
}



data.org <- temp.data[,c("side_b_new","datum","gwno.count","gwno.ratio")]

	

data.org.temp <- data.frame(unique(c(as.yearqtr(seq(min.date, max.date, by = "quarter")),as.yearqtr(max.date))),org.temp)
	names(data.org.temp) <- c("datum","side_b_new")

data.org <- merge(data.org.temp,data.org,by=c("datum","side_b_new"), all.x=TRUE, all.y=FALSE)
		#data.org <- arrange(data.org,datum)

if(i==1){
	trans.prio <- data.org
}

if(i>1){
	trans.prio <- rbind(trans.prio,data.org)	
}



}

load('~/Documents/git/rebelTrack/Rcode/uniq.org.rda')

trans.prio <- merge(trans.prio,uniq.org,by=c("side_b_new"),all.x=TRUE)

save(trans.prio,file="~/Documents/git/rebelTrack/Rcode/transnational/trans.prio.qt.rda")








