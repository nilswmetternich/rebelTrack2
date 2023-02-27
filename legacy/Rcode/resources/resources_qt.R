library(zoo)
library(dplyr)



load('~/Dropbox/elements/coala/multistate/data/ged50.Rdata')


#Let's focus first on state-based violence (type_of_violence==1) where the side_b_dset_id is always a non-state actor (need to make sure that these are always rebel organizations(let's assume for now >1000 <2000))

ged50 <- data.frame(ged50)
	data.all <- ged50[ged50$type_of_vi==1,which(names(ged50)%in%c("side_b_new","date_start","year","priogrid_g") )]
	
data.all$priogrid_g <- as.numeric(as.character(data.all$priogrid_g))

prio.grid <- read.csv("~/Dropbox/elements/coala/multistate/data/PRIO-GRID Yearly Variables for 1989-2014 - 2017-08-01_resources.csv",header=TRUE)





#Diamonds 1946-2005

prio.grid$diamsec_y[is.na(prio.grid$diamsec_y)==TRUE & prio.grid$year<=2005] <- 0

prio.grid$diamprim_y[is.na(prio.grid$diamprim_y)==TRUE & prio.grid$year<=2005] <- 0

#Drugs 1946-2002

prio.grid$drug_y[is.na(prio.grid$drug_y)==TRUE & prio.grid$year<=2002] <- 0


#Gems 1946-2004

prio.grid$gem_y[is.na(prio.grid$gem_y)==TRUE & prio.grid$year<=2004] <- 0


#Gold 1946-2012

prio.grid$goldplacer_y[is.na(prio.grid$goldplacer_y)==TRUE & prio.grid$year<=2012] <- 0
prio.grid$goldvein_y[is.na(prio.grid$goldvein_y)==TRUE & prio.grid$year<=2012] <- 0
prio.grid$goldsurface_y[is.na(prio.grid$goldsurface_y)==TRUE & prio.grid$year<=2012] <- 0


#Petroleum 1946-2003
prio.grid$petroleum_y[is.na(prio.grid$petroleum_y)==TRUE & prio.grid$year<=2003] <- 0





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
		

data.org <- aggregate(data.org[,3:10], by=list(data.org$side_b_new,data.org$datum),FUN=mean,na.rm=TRUE)
	colnames(data.org)[1:2] <- c("side_b_new","datum")

data.org.temp <- data.frame(unique(c(as.yearqtr(seq(min.date, max.date, by = "quarter")),as.yearqtr(max.date))),org.temp)
	names(data.org.temp) <- c("datum","side_b_new")

data.org <- merge(data.org.temp,data.org,by=c("datum","side_b_new"), all.x=TRUE, all.y=FALSE)
		#data.org <- arrange(data.org,datum)

if(i==1){
	resource.prio <- data.org
}

if(i>1){
	resource.prio <- rbind(resource.prio,data.org)	
}



}

load('~/Documents/git/rebelTrack/Rcode/uniq.org.rda')

resource.prio <- merge(resource.prio,uniq.org,by=c("side_b_new"),all.x=TRUE)




# #Diamonds 1946-2005

# resource.prio$diamsec_y[is.na(resource.prio$diamsec_y)==TRUE & resource.prio$datum<="2005-12-31"] <- 0

# resource.prio$diamprim_y[is.na(resource.prio$diamprim_y)==TRUE & resource.prio$datum<="2005-12-31"] <- 0


# #Drugs 1946-2002

# resource.prio$drug_y[is.na(resource.prio$drug_y)==TRUE & resource.prio$datum<="2002-12-31"] <- 0


# #Gems 1946-2004

# resource.prio$gem_y[is.na(resource.prio$gem_y)==TRUE & resource.prio$datum<="2004-12-31"] <- 0



# #Gold 1946-2012

# resource.prio$goldplacer_y[is.na(resource.prio$goldplacer_y)==TRUE & resource.prio$datum<="2012-12-31"] <- 0
# resource.prio$goldvein_y[is.na(resource.prio$goldvein_y)==TRUE & resource.prio$datum<="2012-12-31"] <- 0
# resource.prio$goldsurface_y[is.na(resource.prio$goldsurface_y)==TRUE & resource.prio$datum<="2012-12-31"] <- 0



# #Petroleum 1946-2003
# resource.prio$petroleum_y[is.na(resource.prio$petroleum_y)==TRUE & resource.prio$datum<="2003-12-31"] <- 0












save(resource.prio,file="~/Documents/git/rebelTrack/Rcode/resources/resource.prio.qt.rda")



# pdf(file="resource.pdf",height=5,width=5*1.65)
# plot(resource.prio$datum[resource.prio$organization==1170],resource.prio$drug_y[resource.prio$organization==1170],type="l",axes=F,ann=F)
# axis(1)
# axis(2,las=T)
# title(main="UCDPID=1170",xlab="Months",ylab="drug")
# dev.off()


# plot(resource.prio$datum,resource.prio$drug_y)

# resource.prio[resource.prio$datum<="1990-12-31",]

