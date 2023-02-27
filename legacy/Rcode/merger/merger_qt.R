library(zoo)
library(data.table)
library(plyr)



rm(list = ls())



load("~/Documents/git/rebelTrack/Rcode/area_prio_grid/prio.grids.count.qt.rda")
load("~/Documents/git/rebelTrack/Rcode/battle_deaths/battle.deaths.qt.rda")
load("~/Documents/git/rebelTrack/Rcode/dist_prio_grid/dist.prio.qt.rda")
load("~/Documents/git/rebelTrack/Rcode/mean_fighting/mean.fighting.qt.rda")
load("~/Documents/git/rebelTrack/Rcode/resources/resource.prio.qt.rda")
load("~/Documents/git/rebelTrack/Rcode/static/static.prio.qt.rda")
load("~/Documents/git/rebelTrack/Rcode/transnational/trans.prio.qt.rda")
load("~/Documents/git/rebelTrack/Rcode/urban_grid/urban.prio.qt.rda")
load("~/Documents/git/rebelTrack/Rcode/duration/org.duration.qt.rda")



battle.deaths <- unique(battle.deaths)    
dist.prio  <- unique(dist.prio)      
mean.fighting  <- unique(mean.fighting)    
prio.grids.count <- unique(prio.grids.count) 
resource.prio <- unique(resource.prio)   
static.prio  <- unique(static.prio)     
trans.prio <- unique(trans.prio)
urban.prio <- unique(urban.prio[,c(1,2,8,16)])
org.duration <- unique(org.duration)
   
  
 
dim(battle.deaths)    
dim(dist.prio)      
dim(mean.fighting)    
dim(prio.grids.count) 
dim(resource.prio)   
dim(static.prio)     
dim(trans.prio)
dim(urban.prio)
dim(org.duration)


full.data <- merge(battle.deaths[,-dim(battle.deaths)[2]],dist.prio[,-dim(dist.prio)[2]],by=c("side_b_new","datum"))
full.data <- merge(full.data,org.duration[,-dim(org.duration)[2]],by=c("side_b_new","datum"))
full.data <- merge(full.data,mean.fighting[,-dim(mean.fighting)[2]],by=c("side_b_new","datum"))
full.data <- merge(full.data,prio.grids.count[,-dim(prio.grids.count)[2]],by=c("side_b_new","datum"))
full.data <- merge(full.data,resource.prio[,-dim(resource.prio)[2]],by=c("side_b_new","datum"))
#full.data <- merge(full.data,static.prio[,-dim(static.prio)[2]],by=c("side_b_new","datum"))
full.data <- merge(full.data,trans.prio[,-dim(trans.prio)[2]],by=c("side_b_new","datum"))
full.data <- merge(full.data,urban.prio[,-dim(urban.prio)[2]],by=c("side_b_new","datum"))




full.data <- full.data[is.na(full.data$side_b_new)==FALSE,]

head(full.data)



datum <- full.data$datum
datum.data <- unique(data.frame(datum,as.character(datum)))
names(datum.data) <- c("datum.t","datum")




full.data <- ddply(full.data, .(side_b_new), na.locf,na.rm=FALSE) #check na.locf function for na.rm option


for(i in 3:dim(full.data)[2]){
	full.data[,i] <- as.numeric(full.data[,i])
	
}


          
#dim(full.data)

full.data <- merge(full.data, datum.data,by=c("datum"),all.x=TRUE)

#dim(full.data)

#varN <- c("datum","cmr_max", "cmr_mean","cmr_min","rowend" ,"growstart","petroleum_y ") 

#notwant <- which(colnames(full.data) %in% varN)

library(Amelia)
a.out <- amelia(x = full.data[,-1],m=1,cs = "side_b_new", ts = "datum.t")

data.test <- a.out[[1]][[1]]



varN <- c("time.to.end","latitude", "longitude","cmr_min","rowend" ,"growstart","petroleum_y ") 

notwant <- which(colnames(data.test) %in% varN)
data.test <- data.test[,-notwant]

rebel.track.data <- data.test

save(rebel.track.data,file="~/Dropbox/rebel.track.data.rda")



model.1 <- glm(end~duration+I(duration^2)+I(duration^3),family="binomial",data=data.test)
summary(model.1)
model.1.pred <- predict(model.1,type="response")
table(data.test$end, ifelse(model.1.pred>mean(model.1.pred),1,0))


model.1 <- glm(end~diamsec_y+diamprim_y    +  drug_y   +    gem_y +goldplacer_y + goldvein_y + goldsurface_y +petroleum_y+duration+I(duration^2)+I(duration^3)+deaths_a+deaths_b+I(deaths_a*deaths_b)+capdist+prio.grids.count+bdist1+gwno.count+gwno.ratio+nlights_calib_mean,family="binomial",data=data.test)
summary(model.1)
model.1.pred <- predict(model.1,type="response")
table(model.1$y, ifelse(model.1.pred>mean(model.1.pred),1,0))

plot(data.test$time.to.end,model.1.pred)

data.test.l1 <- data.test
data.test.l1$datum.t <- data.test.l1$datum.t+0.25
test <- merge(data.test,data.test.l1,by=c("side_b_new","datum.t"),suffixes=c("",".lag"),all.x=TRUE)

data.test.l1 <- data.test
data.test.l1$datum.t <- data.test.l1$datum.t+0.5
test <- merge(test,data.test.l1,by=c("side_b_new","datum.t"),suffixes=c("",".lag2"),all.x=TRUE)


model.1 <- glm(end~duration+I(duration^2)+I(duration^3)+prio.grids.count.lag+I(prio.grids.count.lag*duration)+I(prio.grids.count.lag*duration^2),family="binomial",data=test)
summary(model.1)
model.1.pred <- predict(model.1,type="response")
table(model.1$y, ifelse(model.1.pred>mean(model.1.pred),1,0))

model.1 <- glm(end~duration+I(duration^2)+I(duration^3)+prio.grids.count+I(prio.grids.count*duration)+I(prio.grids.count*duration^2)+deaths_b+I(deaths_b*duration)+I(deaths_b*duration^2)+capdist+I(capdist*duration)+I(capdist*duration^2),family="binomial",data=test)
summary(model.1)
model.1.pred <- predict(model.1,type="response")
table(model.1$y, ifelse(model.1.pred>mean(model.1.pred),1,0))

model.1 <- glm(end~time.to.end,family="binomial",data=test)
summary(model.1)


model.1 <- glm(end~I(diamsec_y-diamsec_y.lag)+I(diamprim_y-diamprim_y.lag)  +  I(drug_y - drug_y.lag)  +    I(gem_y-gem_y.lag) +I(goldplacer_y-goldplacer_y.lag) + I(goldvein_y-goldvein_y.lag) + I(goldsurface_y-goldsurface_y.lag) +I(petroleum_y-petroleum_y.lag)+duration+I(duration^2)+I(duration^3)+I(deaths_a-deaths_a.lag)+I(deaths_b-deaths_b.lag)+I(capdist-capdist.lag)+I(prio.grids.count-prio.grids.count.lag)+I(bdist1-bdist1.lag)+I(gwno.count-gwno.count.lag)+I(gwno.ratio-gwno.ratio.lag)+I(nlights_calib_mean-nlights_calib_mean.lag)+diamsec_y+diamprim_y    +  drug_y   +    gem_y +goldplacer_y + goldvein_y + goldsurface_y +petroleum_y+deaths_a+deaths_b+I(deaths_a*deaths_b)+capdist+prio.grids.count+bdist1+gwno.count+gwno.ratio+nlights_calib_mean,family="binomial",data=test)
summary(model.1)
model.1.pred <- predict(model.1,type="response")
table(model.1$y, ifelse(model.1.pred>mean(model.1.pred),1,0))


model.1 <- glm(end~duration+I(duration^2)+I(duration^3)+I(duration^4)+I(deaths_a-deaths_a.lag)+I(deaths_b-deaths_b.lag)+I(capdist-capdist.lag)+I(prio.grids.count-prio.grids.count.lag)+I(bdist1-bdist1.lag)+I(gwno.count-gwno.count.lag)+I(gwno.ratio-gwno.ratio.lag)+I(nlights_calib_mean-nlights_calib_mean.lag)+deaths_a+deaths_b+I(deaths_a*deaths_b)+capdist+prio.grids.count+bdist1+gwno.count+gwno.ratio+nlights_calib_mean,family="binomial",data=test)
summary(model.1)
model.1.pred <- predict(model.1,type="response")
table(model.1$y, ifelse(model.1.pred>mean(model.1.pred),1,0))


model.1 <- glm(end~duration+I(duration^2)+I(duration^3)+I(deaths_a-deaths_a.lag)+I(deaths_b-deaths_b.lag)+I(capdist-capdist.lag)+I(prio.grids.count-prio.grids.count.lag)+I(bdist1-bdist1.lag)+I(gwno.count-gwno.count.lag)+I(gwno.ratio-gwno.ratio.lag)+I(nlights_calib_mean-nlights_calib_mean.lag)+deaths_a+deaths_b+I(deaths_a*deaths_b)+capdist+prio.grids.count+bdist1+gwno.count+gwno.ratio+nlights_calib_mean+I(capdist.lag*duration)+I(deaths_b.lag*duration)+I(prio.grids.count.lag*duration),family="binomial",data=test)
summary(model.1)
model.1.pred <- predict(model.1,type="response")
table(model.1$y, ifelse(model.1.pred>mean(model.1.pred),1,0))




library(separationplot)
 separationplot(model.1.pred,model.1$y)




plot(data.test$datum[data.test==1004],data.test$capdist[data.test==1004])
plot(data.test$datum[data.test==1051],data.test$capdist[data.test==1051])



model.1 <- glm(end~duration+I(duration^2)+I(duration^3)+I(duration^4)+capdist.lag+I(capdist.lag*deaths_b.lag)+deaths_a.lag+deaths_b.lag+bdist3.lag+gwno.count.lag+gwno.ratio.lag,family="binomial",data=test)
summary(model.1)
model.1.pred <- predict(model.1,type="response")
table(model.1$y, ifelse(model.1.pred>mean(model.1.pred),1,0))











