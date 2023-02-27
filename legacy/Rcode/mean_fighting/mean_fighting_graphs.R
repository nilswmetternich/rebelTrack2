library(cshapes)
load("~/Documents/git/rebelTrack/Rcode/mean_fighting/mean.fighting.rda")
load("~/Documents/git/rebelTrack/Rcode/countrysideB.rda")
cmap.2002<-cshp(date=as.Date("2002-1-1"))

load("~/Documents/git/rebelTrack/Rcode/mean_fighting/mean.fighting.rda")
load("~/Documents/git/rebelTrack/Rcode/countrysideB.rda")



gwNO <- 500

org.temp <- as.character(countrysideB$side_b[countrysideB$gwno==gwNO])

country.plot <- cmap.2002[which(cmap.2002$GWCODE %in% gwNO),]

want <- which(mean.fighting$side_b %in% org.temp) 
mean.temp <- mean.fighting[want,]


plot(country.plot)

points(mean.temp$longitude[mean.temp$side_b==org.temp[1]],
    			mean.temp$latitude[mean.temp$side_b==org.temp[1]],pch=16,col="red")

points(mean.temp$longitude[mean.temp$side_b==org.temp[2]],
    			mean.temp$latitude[mean.temp$side_b==org.temp[2]],pch=16,col="blue")

points(mean.temp$longitude[mean.temp$side_b==org.temp[3]],
    			mean.temp$latitude[mean.temp$side_b==org.temp[3]],pch=16,col="green")

points(mean.temp$longitude[mean.temp$side_b==org.temp[4]],
    			mean.temp$latitude[mean.temp$side_b==org.temp[4]],pch=16,col="violet")

points(mean.temp$longitude[mean.temp$side_b==org.temp[5]],
    			mean.temp$latitude[mean.temp$side_b==org.temp[5]],pch=16,col="orange")

points(mean.temp$longitude[mean.temp$side_b==org.temp[6]],
    			mean.temp$latitude[mean.temp$side_b==org.temp[6]],pch=16,col="black")

points(mean.temp$longitude[mean.temp$side_b==org.temp[7]],
    			mean.temp$latitude[mean.temp$side_b==org.temp[7]],pch=16,col="grey")


points(mean.temp$longitude[mean.temp$side_b],
    			mean.temp$latitude[mean.temp$side_b],pch=16)

# Define a server for the Shiny app
function(input, output) {
  


  
  # Fill in the spot we created for a plot
  output$meanPlot <- renderPlot({
   
   country.temp <- countrysideB$gwno[countrysideB$side_b==input$side_b] 
    
   months <- c(1:length(mean.fighting$latitude[mean.fighting$side_b==input$side_b]))
   temp.color <- rgb(1,0,months/max(months),months/max(months))
   
   
   
    # Render a barplot
    
    # plot(mean.fighting$latitude[mean.fighting$side_b==input$side_b],
    			# mean.fighting$longitude[mean.fighting$side_b==input$side_b], 
            # main=input$side_b,
            # ylab="Longitude",
            # xlab="Latitude",
            # col=temp.color,
            # type="p",
            # pch=16)
            
      plot(cmap.2002[which(cmap.2002$GWCODE %in% country.temp),])
      
      points(mean.fighting$longitude[mean.fighting$side_b==input$side_b],
    			mean.fighting$latitude[mean.fighting$side_b==input$side_b],
         		col=temp.color,
                pch=16)
      
     
    # plot(cmap.2002[cmap.2002$GWCODE==2,])
    
    # mean.fighting.temp <- na.omit(mean.fighting)
    
     # for(jj in 1:length(mean.fighting.temp$latitude[mean.fighting.temp$side_b==input$side_b])){
    	
    	 # points(mean.fighting.temp$latitude[mean.fighting.temp$side_b==input$side_b][jj],
    			 # mean.fighting.temp$longitude[mean.fighting.temp$side_b==input$side_b][jj])
    	
     # }      
            
            
  })
}