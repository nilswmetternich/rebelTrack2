library(readxl)

load('~/Dropbox/elements/coala/rebelCast/GEDEvent_v22_1.RData')

ucdp_actor <- read_excel("~/Dropbox/elements/coala/rebelCast/ucdp-actor-221.xlsx")
	ucdp_actor <- ucdp_actor[,c("ActorId","Org")]

state_actors <- ucdp_actor$ActorId[ucdp_actor$Org==4]
nonstate_actors <- ucdp_actor$ActorId[ucdp_actor$Org!=4]
	
GEDEvent_v22_1 <- GEDEvent_v22_1[GEDEvent_v22_1$type_of_violence==1,] #type of violence
	GEDEvent_v22_1 <- GEDEvent_v22_1[which(GEDEvent_v22_1$side_a_new_id %in% state_actors),] # state actors
		GEDEvent_v22_1 <- GEDEvent_v22_1[which(GEDEvent_v22_1$side_b_new_id %in% nonstate_actors),] #non-state actors

save(GEDEvent_v22_1,file='~/Dropbox/elements/coala/rebelCast/GEDEvent_v22_1_temp.RData')
