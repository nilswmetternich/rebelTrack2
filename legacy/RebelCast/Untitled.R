cities <- c("London","Durham","Glasgow","Albuquerque","Wivenhoe","Tallinn","College Station","Zurich","Oslo","Syracuse","Michigan","santaFe","oxford","konstanz")

lat <- c(51.5074,35.9940,55.8642, 35.0853, 51.8580,59.4370,30.6280,47.3769,59.9139,59.3293,43.0392,42.7018,35.6870,52.5200,51.7520,47.6779)

long <- c(-0.1278,-78.8986,-4.2518,-106.6056, 0.9653 ,24.7536, -96.3344,8.5417,10.7522,18.0686,-76.1351,-84.4822,-105.9378,13.4050,-1.2577,9.1732)




library(geosphere)
library(tnet)
library(bipartite)
library(igraph)



#Setting up data set with country information

lon <- c(-0.1278,-78.8986,-4.2518,-106.6056, 0.9653 ,24.7536, -96.3344,8.5417,10.7522,18.0686,-76.1351,-84.4822,-105.9378,13.4050,-1.2577,9.1732)
lat <- c(51.5074,35.9940,55.8642, 35.0853, 51.8580,59.4370,30.6280,47.3769,59.9139,59.3293,43.0392,42.7018,35.6870,52.5200,51.7520,47.677)
ID <- c("conflict1","conflict2","conflict3","conflict4","conflict1","conflict2","conflict3","conflict4","conflict1","conflict2","conflict3","conflict4","conflict1","conflict2","conflict3","conflict4")
country <- c("AFG","AFG","SUD","SUD","AFG","AFG","SUD","SUD","AFG","AFG","SUD","SUD","AFG","AFG","SUD","SUD")
coords <- data.frame(cbind(lon,lat,ID,country))
coords$country <- as.character(coords$country)

#Setting up a list of distMatrix

distMatrix <- list()


#Let's add another loop for countries 

countries <- unique(coords$country)

for(k in 1:length(countries)){

coord <- coords[coords$country==countries[k],]



distMatrix[[k]] <- matrix(NA, nrow=dim(coord)[1],ncol=dim(coord)[1])

colnames(distMatrix[[k]]) <- coord[,3]
rownames(distMatrix[[k]]) <- coord[,3]

for(i in 1:dim(coord)[1]){
	for(j in 1:dim(coord)[1]){
	distMatrix[[k]][i,j]  <- distGeo(c(coord[i,1],coord[i,2]), c(coord[j,1],coord[j,2]))	
	}
}



}
distMatrix 


distMatrix[[1]] <- 1/distMatrix[[1]]
diag(distMatrix[[1]]) <- 0
colnames(distMatrix[[1]]) <- rownames(distMatrix[[1]]) <- c("a","b","c","d","e","f","g","h")
distMatrix[[1]] <- distMatrix[[1]]/max(distMatrix[[1]])



# test <- web2edges(distMatrix[[1]],return=TRUE)
# summary(test)
# test[,2] <- test[,2]-8
# summary(test)
# clustering_w(test)

# ?fastgreedy.community




test <- graph_from_adjacency_matrix(distMatrix[[1]],weighted=TRUE,mode="undirected")
fc <- cluster_fast_greedy(test)
membership(fc)
sizes(fc)





