library(zoo)
library(dplyr)



load('~/Dropbox/elements/coala/multistate/data/ged50.Rdata')


#Let's focus first on state-based violence (type_of_violence==1) where the side_b_dset_id is always a non-state actor (need to make sure that these are always rebel organizations(let's assume for now >1000 <2000))
ged50 <- data.frame(ged50)
data.all <- ged50[ged50$type_of_vi==1,which(names(ged50)%in%c("side_b_dse","date_start") )]

names(data.all) <- c("organization","datum")

data.all <- data.all[data.all$organization>1000 & data.all$organization<2000,]

data.all$organization <- as.character(data.all$organization) 


#################################
#################################

uniq.org <- unique(data.all$organization)

pdf(file="duration_GED.pdf",height=5,width=5*1.65)

plot(1,1,xlim=c(0,1),ylim=c(0,length(uniq.org)),type="n",ann=FALSE,axes=FALSE)


for(i in 1:length(uniq.org)){
	
org.temp <- uniq.org[i]


data.org <- data.all[data.all$organization==org.temp,]



min.date <- min(data.org$datum)
max.date <- max(data.org$datum)

data.org$datum <- as.yearmon(data.org$datum)

data.org$active <- 1


data.org <- aggregate(data.org$active, by=list(data.org$organization,data.org$datum),FUN=sum)
colnames(data.org) <- c("organization","datum","active")



data.org.temp <- data.frame(as.yearmon(seq(min.date, max.date, by = "month")),org.temp)
names(data.org.temp) <- c("datum","organization")

data.org <- merge(data.org.temp,data.org,by=c("datum","organization"), all.x=TRUE, all.y=FALSE)


data.org$active[is.na(data.org$active)==TRUE] <- 0


data.org$active <- ifelse(data.org$active>0,1,0)

data.org <- arrange(data.org,datum)


##########
#Create duration spell for organizations
##########

data.org.spell <- c(min(data.org$datum[data.org$active==1]),max(data.org$datum[data.org$active==1]))



#########
#Create spell IDs on original data "Actor-F/P-Count"
#########

#Subset to time period where actor was ever active
data.org.A <- data.org[which(data.org$datum >= data.org.spell[1] & data.org$datum <= data.org.spell[2]),]

#Generate counter for months within actor spell
data.org.A$month.actor <- 1:dim(data.org.A)[1]

#Generate lag of months to create information about spell type

data.lag <- data.org.A[,which(colnames(data.org.A) %in% c("month.actor","active"))]
data.lag$month.actor <- data.lag$month.actor + 1
data.org.A <- merge(data.org.A, data.lag, by.x=c("month.actor"), by.y=c("month.actor"), all.x=TRUE, all.y=FALSE, suffixes = c("",".lag"))

#This is the first spell
data.org.A$spells.start <- ifelse(data.org.A$month.actor==1,1,0)
#Then there are two different beginnings (fighting and peace spells)
data.org.A$spells.start[data.org.A$active==0 & data.org.A$active.lag==1] <- 1
data.org.A$spells.start[data.org.A$active==1 & data.org.A$active.lag==0] <- 1


#Spell ID
data.org.A$spells.ID <- cumsum(data.org.A$spells.start)


#Peace Spell ID
data.org.A$spells.P.ID <- 0
data.org.A$spells.P.ID[data.org.A$active==0] <- cumsum(data.org.A$spells.start[data.org.A$active==0])

#Fighting Spell ID
data.org.A$spells.F.ID <- 0
data.org.A$spells.F.ID[data.org.A$active==1] <- cumsum(data.org.A$spells.start[data.org.A$active==1])

#Create String
data.org.A$active.string <- ifelse(data.org.A$active==1,"F","P")

#Unique IDs
data.org.A$unique <- NA

data.org.A$unique[data.org.A$active.string=="P"] <- paste(data.org.A$organization[data.org.A$active.string=="P"],data.org.A$active.string[data.org.A$active.string=="P"],data.org.A$spells.P.ID[data.org.A$active.string=="P"],data.org.A$month.actor[data.org.A$active.string=="P"],sep="-")

data.org.A$unique[data.org.A$active.string=="F"] <- paste(data.org.A$organization[data.org.A$active.string=="F"],data.org.A$active.string[data.org.A$active.string=="F"],data.org.A$spells.F.ID[data.org.A$active.string=="F"],data.org.A$month.actor[data.org.A$active.string=="F"],sep="-")

#Unique Spell IDs
data.org.A$unique.spell <- NA

data.org.A$unique.spell[data.org.A$active.string=="P"] <- paste(data.org.A$organization[data.org.A$active.string=="P"],data.org.A$active.string[data.org.A$active.string=="P"],data.org.A$spells.P.ID[data.org.A$active.string=="P"],sep="-")

data.org.A$unique.spell[data.org.A$active.string=="F"] <- paste(data.org.A$organization[data.org.A$active.string=="F"],data.org.A$active.string[data.org.A$active.string=="F"],data.org.A$spells.F.ID[data.org.A$active.string=="F"],sep="-")


by_unique.spell <- group_by(data.org.A, unique.spell)
multi.temp.0 <- summarise(by_unique.spell,
  count = n(),
  org = unique(organization),
  t0 = min(month.actor),
  t1 = max(month.actor),
  start.date = min(datum),
  end.date = max(datum),
  trans.no = max(spells.ID),
  state.from = unique(active.string)
  )
  
 multi.temp.0$event <- 0
 multi.temp.0$state.to <- "O" 
   multi.temp.0$trans.no.ForP <- abs(as.numeric(substr(multi.temp.0$unique.spell,nchar(multi.temp.0$unique.spell)-1,nchar(multi.temp.0$unique.spell))))

 
 
 #generate indicator on average length of previous fighting and peace spells
multi.temp.0 <- arrange(multi.temp.0,trans.no)
multi.temp.0$dur.spell <- multi.temp.0$t1-multi.temp.0$t0+1

multi.temp.0$prev.avg.dur.spell <- (cumsum(multi.temp.0$dur.spell)-multi.temp.0$dur.spell)/(multi.temp.0$trans.no-1)
#Making the assumption that previous peace period was 0. Should we use time since last conflict?
multi.temp.0$prev.avg.dur.spell[substr(multi.temp.0$unique.spell,nchar(multi.temp.0$unique.spell)-2,nchar(multi.temp.0$unique.spell))=="F-1"] <- 0



multi.temp.0$prev.avg.F.dur.spell <- NA
multi.temp.0$prev.avg.F.dur.spell[multi.temp.0$state.from=="F"] <- (cumsum(multi.temp.0$dur.spell[multi.temp.0$state.from=="F"])-multi.temp.0$dur.spell[multi.temp.0$state.from=="F"])/(multi.temp.0$trans.no.ForP[multi.temp.0$state.from=="F"]-1)
#Making the assumption that previous fighting period was 0. Should we use time since last conflict?
multi.temp.0$prev.avg.F.dur.spell[substr(multi.temp.0$unique.spell,nchar(multi.temp.0$unique.spell)-2,nchar(multi.temp.0$unique.spell))=="F-1"] <- 0


multi.temp.0$prev.avg.P.dur.spell <- NA
multi.temp.0$prev.avg.P.dur.spell[multi.temp.0$state.from=="P"] <- (cumsum(multi.temp.0$dur.spell[multi.temp.0$state.from=="P"])-multi.temp.0$dur.spell[multi.temp.0$state.from=="P"])/(multi.temp.0$trans.no.ForP[multi.temp.0$state.from=="P"]-1)
#Making the assumption that previous peace period was 0. Should we use time since last conflict?
multi.temp.0$prev.avg.P.dur.spell[substr(multi.temp.0$unique.spell,nchar(multi.temp.0$unique.spell)-2,nchar(multi.temp.0$unique.spell))=="P-1"] <- 0
multi.temp.0$prev.avg.P.dur.spell[substr(multi.temp.0$unique.spell,nchar(multi.temp.0$unique.spell)-2,nchar(multi.temp.0$unique.spell))=="F-1"] <- 0

multi.temp.0$prev.avg.F.dur.spell.Pview <- NA
multi.temp.0$prev.avg.F.dur.spell.Pview[multi.temp.0$state.from=="F"] <- cumsum(multi.temp.0$dur.spell[multi.temp.0$state.from=="F"])/multi.temp.0$trans.no.ForP[multi.temp.0$state.from=="F"]


multi.temp.0$prev.avg.P.dur.spell.Fview <- NA
multi.temp.0$prev.avg.P.dur.spell.Fview[multi.temp.0$state.from=="P"] <- cumsum(multi.temp.0$dur.spell[multi.temp.0$state.from=="P"])/multi.temp.0$trans.no.ForP[multi.temp.0$state.from=="P"]
#Making the assumption that previous peace period was 0. Should we use time since last conflict?
multi.temp.0$prev.avg.P.dur.spell.Fview[substr(multi.temp.0$unique.spell,nchar(multi.temp.0$unique.spell)-2,nchar(multi.temp.0$unique.spell))=="F-1"] <- 0




want <- which(colnames(multi.temp.0) %in% c("prev.avg.F.dur.spell","prev.avg.P.dur.spell","prev.avg.F.dur.spell.Pview","prev.avg.P.dur.spell.Fview"))

multi.temp.0[,want] <- na.locf(multi.temp.0[,want], na.rm = TRUE) # All missing values attain previos values. This ensures that Fighting periods get correct information about previous peace spells and vice versa.
multi.temp.0[,want] <- na.locf(multi.temp.0[,want], na.rm = TRUE, fromLast=TRUE) # All remaing missing values next values. This ensures that the first fighting period gets information about previous peace period. Currently assumed to be zero. That might not be a good assumption
 


multi.temp.1 <- summarise(by_unique.spell,
  count = n(),
  org = unique(organization),
  t0 = min(month.actor),
  t1 = max(month.actor),
  start.date = min(datum),
  end.date = max(datum),
  trans.no = max(spells.ID),
  state.from = unique(active.string)
  )

 multi.temp.1$event <- 1
 multi.temp.1$state.to <- ifelse(multi.temp.1$state.from=="F","P","F")
  multi.temp.1$trans.no.ForP <- abs(as.numeric(substr(multi.temp.1$unique.spell,nchar(multi.temp.1$unique.spell)-1,nchar(multi.temp.1$unique.spell))))
 
 
#generate indicator on average length of previous fighting and peace spells
multi.temp.1 <- arrange(multi.temp.1,trans.no)
multi.temp.1$dur.spell <- multi.temp.1$t1-multi.temp.1$t0+1

multi.temp.1$prev.avg.dur.spell <- (cumsum(multi.temp.1$dur.spell)-multi.temp.1$dur.spell)/(multi.temp.1$trans.no-1)

#Making the assumption that previous peace period was 0. Should we use time since last conflict?

multi.temp.1$prev.avg.dur.spell[substr(multi.temp.1$unique.spell,nchar(multi.temp.1$unique.spell)-2,nchar(multi.temp.1$unique.spell))=="F-1"] <- 0



multi.temp.1$prev.avg.F.dur.spell <- NA
multi.temp.1$prev.avg.F.dur.spell[multi.temp.1$state.from=="F"] <- (cumsum(multi.temp.1$dur.spell[multi.temp.1$state.from=="F"])-multi.temp.1$dur.spell[multi.temp.1$state.from=="F"])/(multi.temp.1$trans.no.ForP[multi.temp.1$state.from=="F"]-1)

#Making the assumption that previous fighting period was 0. Should we use time since last conflict?

multi.temp.1$prev.avg.F.dur.spell[substr(multi.temp.1$unique.spell,nchar(multi.temp.1$unique.spell)-2,nchar(multi.temp.1$unique.spell))=="F-1"] <- 0


multi.temp.1$prev.avg.P.dur.spell <- NA
multi.temp.1$prev.avg.P.dur.spell[multi.temp.1$state.from=="P"] <- (cumsum(multi.temp.1$dur.spell[multi.temp.1$state.from=="P"])-multi.temp.1$dur.spell[multi.temp.1$state.from=="P"])/(multi.temp.1$trans.no.ForP[multi.temp.1$state.from=="P"]-1)
#Making the assumption that previous peace period was 0. Should we use time since last conflict?
multi.temp.1$prev.avg.P.dur.spell[substr(multi.temp.1$unique.spell,nchar(multi.temp.1$unique.spell)-2,nchar(multi.temp.1$unique.spell))=="P-1"] <- 0
multi.temp.1$prev.avg.P.dur.spell[substr(multi.temp.1$unique.spell,nchar(multi.temp.1$unique.spell)-2,nchar(multi.temp.1$unique.spell))=="F-1"] <- 0


multi.temp.1$prev.avg.F.dur.spell.Pview <- NA
multi.temp.1$prev.avg.F.dur.spell.Pview[multi.temp.1$state.from=="F"] <- cumsum(multi.temp.1$dur.spell[multi.temp.1$state.from=="F"])/multi.temp.1$trans.no.ForP[multi.temp.1$state.from=="F"]


multi.temp.1$prev.avg.P.dur.spell.Fview <- NA
multi.temp.1$prev.avg.P.dur.spell.Fview[multi.temp.1$state.from=="P"] <- cumsum(multi.temp.1$dur.spell[multi.temp.1$state.from=="P"])/multi.temp.1$trans.no.ForP[multi.temp.1$state.from=="P"]
#Making the assumption that previous peace period was 0. Should we use time since last conflict?
multi.temp.1$prev.avg.P.dur.spell.Fview[substr(multi.temp.1$unique.spell,nchar(multi.temp.1$unique.spell)-2,nchar(multi.temp.1$unique.spell))=="F-1"] <- 0


want <- which(colnames(multi.temp.1) %in% c("prev.avg.F.dur.spell","prev.avg.P.dur.spell","prev.avg.F.dur.spell.Pview","prev.avg.P.dur.spell.Fview"))

multi.temp.1[,want] <- na.locf(multi.temp.1[,want], na.rm = TRUE) # All missing values attain previos values. This ensures that Fighting periods get correct information about previous peace spells and vice versa.
multi.temp.1[,want] <- na.locf(multi.temp.1[,want], na.rm = TRUE, fromLast=TRUE) # All remaing missing values next values. This ensures that the first fighting period gets information about previous peace period. Currently assumed to be zero. That might not be a good assumption
 

## 
 
multi.temp <- rbind(multi.temp.0,multi.temp.1)
 
#technically we should identify which groups still exist or not
multi.temp$event[multi.temp$end.date<as.yearmon(as.Date("1/1/2015","%m/%d/%Y")) & multi.temp$end.date == max(multi.temp$end.date) & multi.temp$state.from =="F" & multi.temp$state.to =="O"] <- 1 

multi.temp$event[multi.temp$end.date<as.yearmon(as.Date("1/1/2015","%m/%d/%Y")) & multi.temp$end.date == max(multi.temp$end.date) & multi.temp$state.from =="F" & multi.temp$state.to =="P"] <- 0 


multi.temp$event[multi.temp$end.date==as.yearmon(as.Date("12/1/2015","%m/%d/%Y")) & multi.temp$end.date == max(multi.temp$end.date) & multi.temp$state.from =="F" & multi.temp$state.to =="P"] <- 0  
 
multi.temp <- arrange(multi.temp,trans.no)








if(i==1){
	multi.data <- multi.temp	
}

if(i>1){
	multi.data <- rbind(multi.data,multi.temp)	
}


temp <- table(data.org.A$spells.ID)
temp.x <- cumsum(table(data.org.A$spells.ID))
farbe <- rep(c("blue","red"),100)[1:length(temp.x)]
points(temp.x/max(temp.x),rep(i,length(temp.x/max(temp.x))),col=farbe,pch=16,cex=0.2)




}
axis(1)
title(main="Fighting and Interruption Spells",xlab="Normalized Conflict Duration",ylab="Organizations")
dev.off()

save(multi.data,file="~/Dropbox/Multistate/multi.data.rda")

####
#library(survival)
 #fit <- coxph(Surv(t0, t1+1, event) ~ prev.avg.F.dur.spell+prev.avg.P.dur.spell.Fview+trans.no,data=multi.data[multi.data$state.from=="P"&multi.data$state.to=="F",])



head(multi.data)



head(ged50)
