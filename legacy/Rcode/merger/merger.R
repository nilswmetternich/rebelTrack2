rm(list = ls())

load("~/Documents/git/rebelTrack/Rcode/area_prio_grid/prio.grids.count.rda")
load("~/Documents/git/rebelTrack/Rcode/battle_deaths/battle.deaths.rda")
load("~/Documents/git/rebelTrack/Rcode/dist_prio_grid/dist.prio.rda")
load("~/Documents/git/rebelTrack/Rcode/mean_fighting/mean.fighting.rda")
load("~/Documents/git/rebelTrack/Rcode/resources/resource.prio.rda")
load("~/Documents/git/rebelTrack/Rcode/static/static.prio.rda")
load("~/Documents/git/rebelTrack/Rcode/transnational/trans.prio.rda")
load("~/Documents/git/rebelTrack/Rcode/urban_grid/urban.prio.rda")
load("~/Documents/git/rebelTrack/Rcode/duration/org.duration.rda")



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
full.data <- merge(full.data,static.prio[,-dim(static.prio)[2]],by=c("side_b_new","datum"))
full.data <- merge(full.data,trans.prio[,-dim(trans.prio)[2]],by=c("side_b_new","datum"))
full.data <- merge(full.data,urban.prio[,-dim(urban.prio)[2]],by=c("side_b_new","datum"))


library(Amelia)
a.out <- amelia(x = full.data,m=1,cs = "side_b_new", ts = "datum")

data.test <- a.out[[1]][[1]]

model.1 <- glm(end~duration+I(duration^2)+I(duration^3),family="binomial",data=data.test)
summary(model.1)
model.1.pred <- predict(model.1,type="response")
table(data.test$end, ifelse(model.1.pred>mean(model.1.pred),1,0))


model.1 <- glm(end~diamsec_y+diamprim_y    +  drug_y   +    gem_y +goldplacer_y + goldvein_y + goldsurface_y +petroleum_y+duration+I(duration^2)+I(duration^3)+deaths_a+deaths_b+capdist+prio.grids.count+bdist1+gwno.count+gwno.ratio,family="binomial",data=data.test)
summary(model.1)
model.1.pred <- predict(model.1,type="response")
table(data.test$end, ifelse(model.1.pred>mean(model.1.pred),1,0))








plot(data.test$datum[data.test==1004],data.test$capdist[data.test==1004])
plot(data.test$datum[data.test==1051],data.test$capdist[data.test==1051])

