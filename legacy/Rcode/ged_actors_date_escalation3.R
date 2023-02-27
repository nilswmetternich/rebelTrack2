library(zoo)
library(dplyr)
organization <-c("A","A","A","A","A","A","A","A","A","A","A","A")

datum <- c(
'2000-3-12',
'2000-4-12',
'2000-4-13',
'2000-4-14',
'2000-4-15',
'2000-4-16',
'2000-5-12',
'2000-5-14',
'2000-6-12',
'2000-9-12',
'2000-10-12',
'2000-11-12')



load('~/Dropbox/elements/coala/ged/ged50.Rdata')


#Let's focus first on state-based violence (type_of_violence==1) where the side_b_dset_id is always a non-state actor (need to make sure that these are always rebel organizations(let's assume for now >1000 <2000))
ged50 <- data.frame(ged50)
data.all <- ged50[ged50$type_of_vi==1,which(names(ged50)%in%c("side_b_dse","date_start","gwab") )]

names(data.all) <- c("organization","datum","conflict")

data.all <- data.all[data.all$organization>1000 & data.all$organization<2000,]

data.all$organization <- as.character(data.all$organization) 
data.all$conflict <- as.character(data.all$conflict) 

#This is to just look at active days

data.all <- unique(data.all)

#################################
#################################

uniq.conflict <- unique(data.all$conflict)

for(j in 1:length(uniq.conflict)){

temp.conflict <- uniq.conflict[j]

uniq.org <- unique(data.all$organization[data.all$conflict==temp.conflict])

data.conf <- data.all[data.all$conflict==temp.conflict,]


min.date <- min(data.conf$datum)
max.date <- max(data.conf$datum)

data.conf$datum <- as.yearmon(data.conf$datum)

data.conf$active <- 1


data.conf <- aggregate(data.conf$active, by=list(data.conf$conflict,data.conf$datum),FUN=sum)
colnames(data.conf) <- c("conflict","datum","active")

data.conf.temp <- data.frame(as.yearmon(seq(min.date, max.date, by = "month")),temp.conflict)
names(data.conf.temp) <- c("datum","conflict")

data.conf <- merge(data.conf.temp,data.conf,by=c("datum","conflict"), all.x=TRUE, all.y=FALSE)


data.conf$active[is.na(data.conf$active)==TRUE] <- 0


#data.org$active <- ifelse(data.org$active>0,1,0)

data.conf <- arrange(data.conf,datum)

help <- ceiling(sqrt(length(uniq.org)))

setwd("~/Desktop/temp1")
pdf(file=paste(temp.conflict,"pdf",sep="."))
par(mfrow=c(help,help))

#plot(data.conf$datum,data.conf$active,type="l")


for(i in 1:length(uniq.org)){
	
org.temp <- uniq.org[i]

#are some actors in different conflicts
data.org <- data.all[data.all$organization==org.temp & data.all$conflict==temp.conflict,]

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


#data.org$active <- ifelse(data.org$active>0,1,0)

data.org <- arrange(data.org,datum)

if(i==1 & j==1){
	data.escalation <- data.org
	
}

if(i!=1 & j!=1){
	data.escalation <- rbind(data.escalation,data.org)
	
}


plot(data.conf$datum,data.conf$active,type="l",col="grey")
lines(data.org$datum,data.org$active,col="red")
}
dev.off()
}



pdf(file="escalation.pdf",height=5,width=5*1.65)
plot(data.escalation$datum[data.escalation$organization==1170],data.escalation$active[data.escalation$organization==1170],type="l",axes=F,ann=F)
axis(1)
axis(2,las=T)
title(main="UCDPID=1170",xlab="Months",ylab="Number of fighting events")
dev.off()





# #########
# #Create spell IDs on original data "Actor-F/P-Count"
# #########

# #Generate counter for months within actor spell
# data.org$month.actor <- 1:dim(data.org)[1]

# data.org$month.actor.norm <- data.org$month.actor/max(data.org$month.actor)
# data.org$active.norm <- data.org$active/max(data.org$active)



# #lines(data.org$month.actor.norm,data.org$active.norm,lwd=0.05)

# points(data.org$month.actor.norm[data.org$active.norm==max(data.org$active.norm)],data.org$active.norm[data.org$active.norm==max(data.org$active.norm)],col="blue",pch=16,cex=0.2)


# max.value.all[[i]] <- data.org$month.actor.norm[data.org$active.norm==max(data.org$active.norm)]

# value.a[[i]] <- data.org$month.actor.norm
# value.b[[i]] <- data.org$active.norm
# value.c[[i]] <- rep(i,length(data.org$active))
# value.d[[i]] <- data.org$organization

# p.low <- lowess(data.org$month.actor.norm, data.org$active.norm, f = 1/10)
# lines(p.low$x,p.low$y,lwd=0.05)
# points(p.low$x[p.low$y==max(p.low$y)],p.low$y[p.low$y==max(p.low$y)],col="red",pch=16)

# max.values[i] <- p.low$x[p.low$y==max(p.low$y)][1]
# max.values.n[i] <- data.org$month.actor.norm[data.org$active.norm==max(data.org$active.norm)][1]


# }


# hist(max.values)
# hist(max.values.n)
# hist(unlist(max.value.all))

# plot(unlist(value.a),unlist(value.b),col=rgb(unlist(value.c)/max(unlist(value.c)),0,0,1),pch=16,cex=0.2)
# #text(unlist(value.a),unlist(value.b),labels=unlist(value.d))

# model.null <- glm(ifelse(unlist(value.b)>mean(unlist(value.b)),1,0)~unlist(value.a)+I(unlist(value.a)^2)+I(unlist(value.a)^3)+I(unlist(value.a)^4),family="binomial")

# model.null <- glm(ifelse(unlist(value.b)>0.5,1,0)~unlist(value.a)+I(unlist(value.a)^2)+I(unlist(value.a)^3)+I(unlist(value.a)^4)+I(unlist(value.a)^5),family="binomial")


# summary(model.null)
# hi <- predict(model.null,type="response")

# hist(hi[ifelse(unlist(value.b)>mean(unlist(value.b)),1,0)==0])


# mean(unlist(value.b))
