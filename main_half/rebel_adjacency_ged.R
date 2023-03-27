#this file produces adjacency matrices for every year
#these can then be accumulated on need.

load('~/Dropbox/elements/coala/rebelCast/GEDEvent_v22_1_temp.RData')


ucdp_ged <- GEDEvent_v22_1[,c("side_a_new_id","side_a","side_b_new_id","side_b","date_start")]
	ucdp_ged$date_start <- as.Date(substr(ucdp_ged$date_start,1,10))
		ucdp_ged$date_start <- lubridate::floor_date(ucdp_ged$date_start,unit = "year")	

ucdp_ged$side_a_new_id_same <- ucdp_ged$side_a_new_id


ucdp_ged.a <- ucdp_ged[,c("side_a","side_a_new_id","date_start","side_a_new_id_same")]
ucdp_ged.b <- ucdp_ged[,c("side_b","side_b_new_id","date_start","side_a_new_id_same")]

names(ucdp_ged.a) <- c("side","side_id","date_start","side_a_new_id_same")
names(ucdp_ged.b) <- c("side","side_id","date_start","side_a_new_id_same")
		
ucdp_ged <- dplyr::bind_rows(ucdp_ged.a,ucdp_ged.b)

ucdp_ged <- unique(ucdp_ged)

ucdp_ged <- arrange(ucdp_ged,side_id,date_start)

actors <- unique(c(as.character(ucdp_ged$side_id)))
time.unit <- as.character(unique(ucdp_ged$date_start))

array.c <- array(0,c(length(actors),length(actors),length(time.unit)),dimnames=list(actors,actors,time.unit))



for(k in time.unit){
	temp.ged <- ucdp_ged[as.character(ucdp_ged$date_start)==k,]
	print(k)
		for(i in 1:dim(temp.ged)[1]){
			for(j in 1:dim(temp.ged)[1]){
		if(temp.ged$side_a_new_id_same[i]==temp.ged$side_a_new_id_same[j]){
			array.c[as.character(temp.ged$side_id[i]),as.character(temp.ged$side_id[j]),k] <- 1
		}
		}}}


#Version 1: Connected if you have fought with the same government thoughout the observation period

to.plot <- which(dimnames(array.c)[[3]] %in% dimnames(array.c)[[3]])

Mat <-  apply(array.c[,,to.plot],c(1,2),FUN=sum)

Mat[Mat>1] <- 1

save(Mat, file='~/Dropbox/elements/coala/rebelCast/Mat_v1.rda')





#Plotting  year intervals
# to.plot <- which(dimnames(array.c)[[3]] %in% dimnames(array.c)[[3]])

# Mat <-  apply(array.c[,,to.plot],c(1,2),FUN=sum)

# Mat[Mat>1] <- 1


# net2 <- graph_from_adjacency_matrix(Mat,mode = "undirected", diag = FALSE, weighted=TRUE)
# #strength(net2)
# E(net2)$arrow.mode <- 0
# E(net2)$width <- E(net2)$weight/6
# V(net2)$size <- 0.1
# l <- layout_in_circle(net2)
# plot(net2, main="Relations",layout=l,vertex.label=dimnames(array.c)[[1]], vertex.frame.color="#ffffff",vertex.label.color="black",edge.arrow.size=.2, edge.color="orange",
     # vertex.color="orange",vertex.label.cex=.5,edge.curved=.2)

							
