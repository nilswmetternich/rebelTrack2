

load('~/Dropbox/Multistate/data/inputData/ged50/ged50.Rdata')

ged50 <- ged50[ged50$type_of_vi==1 & ged50$where_prec==1,]
ged50 <- ged50[,c("side_b_new","latitude","longitude")]



library(geosphere)
library(tnet)
library(bipartite)
library(igraph)



coord <- data.frame(ged50)

coord <- unique(coord)
coord <- coord[1:5000,]


dyad.coord <- data.frame(rep(coord$side_b_new,dim(coord)[1]),rep(coord$side_b_new,each=dim(coord)[1]),rep(coord$longitude,dim(coord)[1]),rep(coord$longitude,each=dim(coord)[1]),rep(coord$latitude,dim(coord)[1]),rep(coord$latitude,each=dim(coord)[1]))

colnames(dyad.coord) <- c("side_b_new.x","side_b_new.y","longitude.x","longitude.y","latitude.x","latitude.y")

dyad.coord$geo.dist <- distGeo(cbind(dyad.coord$longitude.x,dyad.coord$latitude.x), cbind(dyad.coord$longitude.y,dyad.coord$latitude.y))	


distMatrix <- matrix(dyad.coord$geo.dist, nrow=dim(coord)[1],ncol=dim(coord)[1],byrow=TRUE)

colnames(distMatrix) <- coord[,1]
rownames(distMatrix) <- coord[,1]



distMatrix[distMatrix==0] <- 1
distMatrix <- 1/(distMatrix)
diag(distMatrix) <- 0
distMatrix <- distMatrix/max(distMatrix)


distMatrix.2 <- distMatrix

distMatrix <- 1-distMatrix

# test <- web2edges(distMatrix[[1]],return=TRUE)
# summary(test)
# test[,2] <- test[,2]-8
# summary(test)
# clustering_w(test)

# ?fastgreedy.community

distMatrix <- 10*distMatrix


test <- graph_from_adjacency_matrix(distMatrix,weighted=TRUE,mode="undirected")
fc <- cluster_fast_greedy(test)
members.fc <- membership(fc)
size.fc <- sizes(fc)

plot(coord[1:5000,3],coord[1:5000,2],type="n")

text(coord[1:5000,3],coord[1:5000,2],members.fc)

