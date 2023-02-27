library(zoo)
library(dplyr)

# Here we want to load the GED data through their API
load('~/Dropbox/Multistate/data/inputData/ged50/ged50.Rdata')


# This is aggregating events to monthly level. 


count.ged.events <- function(type="1",side="side_b_new"){ #This function allows selection of violence type and which side (a or b) should be included. Weekly, monthly, yearly option needs to be included


	ged50 <- data.frame(ged50) #transform to data.frame
		data.all <- ged50[ged50$type_of_vi==as.numeric(type),which(names(ged50)%in%c(side,"date_start") )] # select type of violence and side
			colnames(data.all) <- c("side","date_start")
			
# Need to include ability to add further variables

# creat uniq organizations
	uniq.org <- unique(data.all$side)  


for(i in 1:length(uniq.org)){ # for each organization 
	org.temp <- uniq.org[i]
		data.org <- data.all[data.all$side==org.temp,]

min.date <- min(data.org$date_start) # create min max dates 
max.date <- max(data.org$date_start)

data.org$datum <- as.yearmon(data.org$date_start) # generate monthly variable (here we want to include option of weekley and yearly)
		data.org$active <- 1 # This is an indicator to aggregate to the number of events

data.org <- aggregate(data.org$active, by=list(data.org$side,data.org$datum),FUN=sum) # aggregate how many events in observed months
	colnames(data.org) <- c("side","datum","event.count") 

data.org.temp <- data.frame(as.yearmon(seq(min.date, max.date, by = "month")),org.temp) # Generate empty data frame with all dates
	names(data.org.temp) <- c("datum","side")

data.org <- merge(data.org.temp,data.org,by=c("datum","side"), all.x=TRUE, all.y=FALSE) # merging data.org.temp,data.org
	data.org$event.count[is.na(data.org$event.count)==TRUE] <- 0
		#data.org <- arrange(data.org,datum)

if(i==1){
	event.count <- data.org     #create new dataset for first organization
}

if(i>1){
	event.count <- rbind(event.count,data.org)	# add data for all other organizations
}


}
return(event.count)
}


#Example
one.sided <- count.ged.events(type="3",side="side_a_new")
