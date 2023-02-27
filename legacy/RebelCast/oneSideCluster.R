# cities <- c("London","Durham","Glasgow","Albuquerque","Wivenhoe","Tallinn","College Station","Zurich","Oslo","Syracuse","Michigan","santaFe","oxford","konstanz")

# lat <- c(51.5074,35.9940,55.8642, 35.0853, 51.8580,59.4370,30.6280,47.3769,59.9139,59.3293,43.0392,42.7018,35.6870,52.5200,51.7520,47.6779)

# long <- c(-0.1278,-78.8986,-4.2518,-106.6056, 0.9653 ,24.7536, -96.3344,8.5417,10.7522,18.0686,-76.1351,-84.4822,-105.9378,13.4050,-1.2577,9.1732)




load('~/Dropbox/Multistate/data/inputData/ged50/ged50.Rdata')


ged50.one <- ged50[ged50$type_of_vi==3 & ged50$where_prec==1,]
ged50.one <- ged50.one[,c("side_a_new","latitude","longitude")]

ged50 <- ged50[ged50$type_of_vi==1 & ged50$where_prec==1,]
ged50 <- ged50[,c("side_b_new","latitude","longitude")]


library(geosphere)
library(tnet)
library(bipartite)
library(igraph)



# #Setting up data set with country information

# lon <- c(-0.1278,-78.8986,-4.2518,-106.6056, 0.9653 ,24.7536, -96.3344,8.5417,10.7522,18.0686,-76.1351,-84.4822,-105.9378,13.4050,-1.2577,9.1732)
# lat <- c(51.5074,35.9940,55.8642, 35.0853, 51.8580,59.4370,30.6280,47.3769,59.9139,59.3293,43.0392,42.7018,35.6870,52.5200,51.7520,47.677)
# ID <- c("conflict1","conflict2","conflict3","conflict4","conflict1","conflict2","conflict3","conflict4","conflict1","conflict2","conflict3","conflict4","conflict1","conflict2","conflict3","conflict4")
# country <- c("AFG","AFG","SUD","SUD","AFG","AFG","SUD","SUD","AFG","AFG","SUD","SUD","AFG","AFG","SUD","SUD")
# coords <- data.frame(cbind(lon,lat,ID,country))
# coords$country <- as.character(coords$country)

# #Setting up a list of distMatrix

distMatrix <- list()
memberClusters <- list()
sizeClusters <- list()
coordActors <- list()
coordOneSided <- list()

#Let's add another loop for countries 

actors <- unique(ged50$side_b_new)

for(k in 1:length(actors)){


if(dim(ged50.one[ged50.one$side_a_new==actors[k],])[1]>0){
	coord.one <- data.frame(ged50.one[ged50.one$side_a_new==actors[k],])	
		coordOneSided[[k]] <- coord.one <- unique(coord.one)
}

if(dim(ged50.one[ged50.one$side_a_new==actors[k],])[1]==0){
		coordOneSided[[k]] <- NA
}





coord <- data.frame(ged50[ged50$side_b_new==actors[k],])

coordActors[[k]] <- coord <- unique(coord)



dyad.coord <- data.frame(rep(coord$side_b_new,dim(coord)[1]),rep(coord$side_b_new,each=dim(coord)[1]),rep(coord$longitude,dim(coord)[1]),rep(coord$longitude,each=dim(coord)[1]),rep(coord$latitude,dim(coord)[1]),rep(coord$latitude,each=dim(coord)[1]))

colnames(dyad.coord) <- c("side_b_new.x","side_b_new.y","longitude.x","longitude.y","latitude.x","latitude.y")

dyad.coord$geo.dist <- distGeo(cbind(dyad.coord$longitude.x,dyad.coord$latitude.x), cbind(dyad.coord$longitude.y,dyad.coord$latitude.y))	


distMatrix[[k]] <- matrix(dyad.coord$geo.dist, nrow=dim(coord)[1],ncol=dim(coord)[1],byrow=TRUE)

colnames(distMatrix[[k]]) <- coord[,1]
rownames(distMatrix[[k]]) <- coord[,1]


distMatrix[[k]] <- 1/(distMatrix[[k]])
diag(distMatrix[[k]]) <- 0
distMatrix[[k]] <- distMatrix[[k]]/max(distMatrix[[k]])

test <- graph_from_adjacency_matrix(distMatrix[[k]],weighted=TRUE,mode="undirected")
fc <- cluster_fast_greedy(test)
memberClusters[[k]] <- membership(fc)
sizeClusters[[k]] <- sizes(fc)

}



dim.fun <- function(x){
	return <- dim(x)[1]
	}

size.CL <- lapply(sizeClusters,FUN=length)
event.C <- lapply(distMatrix,FUN=dim.fun)
one.C <- lapply(coordOneSided,FUN=dim.fun)

for(kk in 1:length(actors)){
if(is.null(one.C[[kk]])==TRUE){
one.C[[kk]] <- 0
}
}
one.un <- unlist(one.C)

boxplot(unlist(event.C)~unlist(size.CL))

boxplot(one.un~unlist(size.CL))

plot(unlist(event.C)~one.un)

summary(lm(one.un~unlist(event.C)+unlist(size.CL)))

library(MASS)
summary(glm.nb(one.un~unlist(event.C)+unlist(size.CL)))

library(pscl)
summary(m1 <- zeroinfl(one.un ~ unlist(event.C)+unlist(size.CL) | unlist(event.C)+unlist(size.CL)))

plot(coordActors[[k]]$longitude,coordActors[[k]]$latitude,col=rgb(memberClusters[[k]]/max(memberClusters[[k]]),1-memberClusters[[k]]/max(memberClusters[[k]]),memberClusters[[k]]/max(memberClusters[[k]]),1))

points(coordOneSided[[k]]$longitude,coordOneSided[[k]]$latitude)

