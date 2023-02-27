library(zoo)
library(dplyr)



load('~/Dropbox/elements/coala/multistate/data/ged50.Rdata')


#Let's focus first on state-based violence (type_of_violence==1) where the side_b_dset_id is always a non-state actor (need to make sure that these are always rebel organizations(let's assume for now >1000 <2000))

ged50 <- data.frame(ged50)
	data.all <- ged50[ged50$type_of_vi==1,which(names(ged50)%in%c("side_b_new","date_start","priogrid_g") )]

data.all$priogrid_g <- as.numeric(as.character(data.all$priogrid_g))


prio.grid <- read.csv("~/Dropbox/elements/coala/multistate/data/PRIO-GRID Static Variables - 2017-08-07.csv",header=TRUE)

prio.grid$diamsec_s[is.na(prio.grid$diamsec_s)==TRUE] <- 0      
prio.grid$diamprim_s[is.na(prio.grid$diamprim_s)==TRUE] <- 0     
prio.grid$gem_s[is.na(prio.grid$gem_s)==TRUE] <- 0            
prio.grid$goldplacer_s[is.na(prio.grid$goldplacer_s)==TRUE] <- 0         
prio.grid$goldvein_s[is.na(prio.grid$goldvein_s)==TRUE] <- 0   
prio.grid$goldsurface_s[is.na(prio.grid$goldsurface_s)==TRUE] <- 0    
prio.grid$petroleum_s[is.na(prio.grid$petroleum_s)==TRUE] <- 0   

#data.all$year[data.all$year>2014] <- 2014 #this is a fix because prio grid only goes to 2014

data.all <- merge(data.all,prio.grid,by.x=c("priogrid_g"),by.y=c("gid"),all.x=TRUE) 


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
		

data.org <- aggregate(data.org[,3:40], by=list(data.org$side_b_new,data.org$datum),FUN=mean,na.rm=TRUE)
	colnames(data.org)[1:2] <- c("side_b_new","datum")

data.org.temp <- data.frame(unique(c(as.yearqtr(seq(min.date, max.date, by = "quarter")),as.yearqtr(max.date))),org.temp)
	names(data.org.temp) <- c("datum","side_b_new")

data.org <- merge(data.org.temp,data.org,by=c("datum","side_b_new"), all.x=TRUE, all.y=FALSE)
		#data.org <- arrange(data.org,datum)

if(i==1){
	static.prio <- data.org
}

if(i>1){
	static.prio <- rbind(static.prio,data.org)	
}



}

load('~/Documents/git/rebelTrack/Rcode/uniq.org.rda')

static.prio <- merge(static.prio,uniq.org,by=c("side_b_new"),all.x=TRUE)

save(static.prio,file="~/Documents/git/rebelTrack/Rcode/static/static.prio.qt.rda")









