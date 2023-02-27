load('~/Documents/git/rebelTrack/legacy/data/ucdp-dyadic-172.RData')

library(network)
library(sna)
library(igraph)

head(ucdp.dyadic)
dim(ucdp.dyadic)
# Select type of conflict (internal/internationalized)
# From the UCDP dyadic codebook
		#3.14 Type: A dyad can be active in four different types of conflict:				# 1 Extrasystemic armed conflict occurs between a state and a non-state group outside its own territory. (In the COW project, extrasystemic war is subdivided into
				# colonial war and imperial war, but this distinction is not used here.) These conflicts are by definition territorial, since the government side is fighting to retain
				# control of a territory outside the state system.				# 2 Interstate armed conflict occurs between two or more states.				# 3 Internal armed conflict occurs between the government of a state and one or more internal opposition group(s) without intervention from other states.				# 4 Internationalized internal armed conflict occurs between the government of a state and one or more internal opposition group(s) with intervention from other states
				# (secondary parties) on one or both sides.
				
# select internal conflict types
data.dyadic <- ucdp.dyadic[ucdp.dyadic$type_of_conflict == 3 | ucdp.dyadic$type_of_conflict == 4,]	dim(data.dyadic)

# generate unique list of actors that are in conflict with governments
actor.list <- unique(data.dyadic$side_b_id)
	length(actor.list)

# generate unique list of actors involved in respective conflicts
actor.conflict.list <- unique(data.dyadic[,c("side_b_id","conflict_id")])
	dim(actor.conflict.list)

# generate unique list of actors fighting with respective governments
actor.government.list <- unique(data.dyadic[,c("side_b_id","gwno_a")])
	dim(actor.government.list)


# generate cross-sectional connectivity matrices for actors
actor.government.Matrix <- actor.conflict.Matrix <- matrix(0,nrow=length(actor.list),ncol=length(actor.list))
	colnames(actor.government.Matrix) <- rownames(actor.government.Matrix)  <- colnames(actor.conflict.Matrix) <- rownames(actor.conflict.Matrix) <- actor.list


# identify links in actor.conflict.Matrix

for(i in 1:dim(actor.conflict.list)[1]){	
	for(j in 1:dim(actor.conflict.list)[1]){
		
		if(actor.conflict.list$conflict_id[i] == actor.conflict.list$conflict_id[j]){
				actor.conflict.Matrix[as.character(actor.conflict.list$side_b_id[i]),as.character(actor.conflict.list$side_b_id[j])] <- 1}	
			
}
}

# identify links in actor.government.Matrix

for(i in 1:dim(actor.government.list)[1]){	
	for(j in 1:dim(actor.government.list)[1]){
		
		if(actor.government.list$gwno_a[i] == actor.government.list$gwno_a[j]){
				actor.government.Matrix[as.character(actor.government.list$side_b_id[i]),as.character(actor.government.list$side_b_id[j])] <- 1}	
			
}
}




# plot actor.government.Matrix
##net <- as.network(actor.government.Matrix,matrix.type="adjacency",directed=FALSE)
##plot(net,label=actor.list,vertex.col="grey",vertex.border="black",edge.lwd=(actor.conflict.Matrix))
##plot(net,vertex.col="grey",vertex.border="black",edge.lwd=0.01,vertex.cex=0.1)



# Need to create time-varying matrix that connects active groups based on the time scale chosen 







