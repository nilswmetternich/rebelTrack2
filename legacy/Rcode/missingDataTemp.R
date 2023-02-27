library(Amelia)

amelia(data,m=5,cs="actor",ts="period_start",intercs=TRUE,polytime=3,incheck=FALSE,p2s=2,tolerance=0.0005,outname="p3ny",empri=0.1,emburn=c(0,75))