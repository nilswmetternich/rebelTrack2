library(zoo)
library(dplyr)



load('~/Dropbox/elements/coala/multistate/data/ged50.Rdata')


#Let's focus first on state-based violence (type_of_violence==1) where the side_b_dset_id is always a non-state actor (need to make sure that these are always rebel organizations(let's assume for now >1000 <2000))

ged50 <- data.frame(ged50)
	data.all <- ged50[ged50$type_of_vi==1,which(names(ged50)%in%c("side_b","side_b_new","gwno") )]
#################################
#################################

countrysideB <- unique(data.all)


save(countrysideB,file='~/Documents/git/rebelTrack/Rcode/countrysideB.rda')