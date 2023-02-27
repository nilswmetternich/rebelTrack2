
load("~/Documents/git/rebelTrack/Rcode/dist_prio_grid/dist.prio.rda")

# Define a server for the Shiny app
function(input, output) {
  
  # Fill in the spot we created for a plot
  output$distPlot <- renderPlot({
    
    # Render a barplot
    plot(dist.prio$datum[dist.prio$side_b==input$side_b],
    			dist.prio$capdist[dist.prio$side_b==input$side_b], 
            main=input$side_b,
            ylab="Mean distance to captital",
            xlab="Month",
            type="l")
  })
}


