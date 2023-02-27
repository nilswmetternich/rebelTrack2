library(zoo)
library(dplyr)


load('~/Dropbox/elements/coala/ged/ged50.Rdata')


count.ged.events <- function(type="1",side="side_b_new"){


	ged50 <- data.frame(ged50) #transform to data.frame
		data.all <- ged50[ged50$type_of_vi==as.numeric(type),which(names(ged50)%in%c(side,"date_start") )] # select type of violence and side
			colnames(data.all) <- c("side","date_start")
			

# creat uniq organizations
	uniq.org <- unique(data.all$side) 


for(i in 1:length(uniq.org)){
	org.temp <- uniq.org[i]
		data.org <- data.all[data.all$side==org.temp,]

min.date <- min(data.org$date_start)
max.date <- max(data.org$date_start)

data.org$datum <- as.yearmon(data.org$date_start)
		data.org$active <- 1

data.org <- aggregate(data.org$active, by=list(data.org$side,data.org$datum),FUN=sum)
	colnames(data.org) <- c("side","datum","event.count")

data.org.temp <- data.frame(as.yearmon(seq(min.date, max.date, by = "month")),org.temp)
	names(data.org.temp) <- c("datum","side")

data.org <- merge(data.org.temp,data.org,by=c("datum","side"), all.x=TRUE, all.y=FALSE)
	data.org$event.count[is.na(data.org$event.count)==TRUE] <- 0
		#data.org <- arrange(data.org,datum)

if(i==1){
	event.count <- data.org
}

if(i>1){
	event.count <- rbind(event.count,data.org)	
}


}
	if(type=="1"){
	colnames(event.count) <- c("datum","side","event.count.type.1")}
	if(type=="2"){
	colnames(event.count) <- c("datum","side","event.count.type.2")}
	if(type=="3"){
	colnames(event.count) <- c("datum","side","event.count.type.3")}

return(unique(event.count))
}

#Example
#one.sided <- count.ged.events(type="3",side="side_a_new")
