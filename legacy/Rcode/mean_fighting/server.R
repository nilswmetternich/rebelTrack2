library(cshapes)
load("~/Documents/git/rebelTrack/Rcode/mean_fighting/mean.fighting.rda")
load("~/Documents/git/rebelTrack/Rcode/countrysideB.rda")
cmap.2002<-cshp(date=as.Date("2002-1-1"))


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

