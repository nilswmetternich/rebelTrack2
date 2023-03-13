load('~/Dropbox/elements/coala/rebelCast/ged_merge.rda')
load('~/Dropbox/elements/coala/rebelCast/Mat_v1.rda')


time.periods <- unique(ged_merge$date_start)


for(i in 1:length(time.periods)){
ged_temp <- ged_merge[ged_merge$date_start==time.periods[i],]
	id_temp <- as.character(ged_temp$side_id)
		Mat_temp <- Mat[id_temp,id_temp]
			  if (sum(as.numeric(id_temp)-as.numeric(colnames(Mat_temp))) != 0) {
    stop("vector and matrix not in correct order")
  }
			ged_temp$best.sp <- as.vector(ged_temp$best %*% Mat_temp)
			ged_temp$days.sp <- as.vector(ged_temp$days %*% Mat_temp)
			ged_temp$mean.bdist3.sp <- as.vector(ged_temp$mean.bdist3 %*% Mat_temp)
			ged_temp$mean.capdist.sp <- as.vector(ged_temp$mean.capdist %*% Mat_temp)
			ged_temp$events.sp <- as.vector(ged_temp$events %*% Mat_temp)
			ged_temp$grids.sp <- as.vector(ged_temp$grids %*% Mat_temp)
			ged_temp$transnational_ratio.sp <- as.vector(ged_temp$transnational_ratio %*% Mat_temp)
			
	
			
			ged_temp <- ged_temp[,which(names(ged_temp) %in% c("side_id","date_start",grep(".sp",names(ged_temp),value=TRUE)))]


			if(i==1){
				ged_spatial <- ged_temp
			}
			
			if(i>1){
				ged_spatial <- dplyr::bind_rows(ged_spatial,ged_temp)
			}
			print(time.periods[i])
			}
			
dim(ged_spatial)==dim(ged_merge)

ged_merge_sp <- left_join(ged_merge,ged_spatial)

save(ged_merge_sp,file='~/Dropbox/elements/coala/rebelCast/ged_merge_sp.rda')
