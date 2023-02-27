valueActor <- c(3,5,3,1)
Actor <- c("A","B","C","D")
valueActor <- data.frame(valueActor,Actor)
rownames(valueActor) <- c("A","B","C","D")
connect <- matrix(c(0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0),nrow=4,ncol=4)
colnames(connect) <- rownames(connect) <- c("A","B","C","D")
connect%*%valueActor$valueActor



spatialLags <- function(Mat=connect,data=valueActor,dataID = "Actor",dataValue = "valueActor"){
	
	idNames <- as.character(data[,dataID])
	values <- data[,dataValue]
	
	temp.data <- data.frame(idNames,values)
	temp.data <- arrange(temp.data,idNames)
	
	Mat <- Mat[order(rownames(Mat)),order(colnames(Mat))]
	
	return(temp.data[,2]%*%Mat)
	
	
}



spatialLags(Mat=connect,data=valueActor,dataID = "Actor",dataValue = "valueActor")


#############
#with years
#############
outPut <- list()


valueActor <- c(3,5,3,1,3,5,3,1)
Actor <- c("A","B","C","D","A","B","C","D")
year <- c(rep(1,4),rep(2,4))
valueActor <- data.frame(valueActor,Actor,year)

connect <- matrix(c(0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0),nrow=4,ncol=4)
colnames(connect) <- rownames(connect) <- c("A","B","C","D")

Connect <- list()
Connect[[1]] <- connect
Connect[[2]] <- connect

for(i in 1:2){
outPut[[i]] <- spatialLags(Mat=Connect[[i]],data=valueActor[valueActor$year==i,],dataID = "Actor",dataValue = "valueActor")	
	
}