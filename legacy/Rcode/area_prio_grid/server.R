
load("~/Documents/git/rebelTrack/Rcode/area_prio_grid/prio.grids.count.rda")

# Define a server for the Shiny app
function(input, output) {
  
  # Fill in the spot we created for a plot
  output$areaPlot <- renderPlot({
    
    # Render a barplot
    plot(prio.grids.count$datum[prio.grids.count$side_b==input$side_b],
    			prio.grids.count$prio.grids.count[prio.grids.count$side_b==input$side_b], 
            main=input$side_b,
            ylab="Count PRIO Grids",
            xlab="Month",
            type="l")
  })
}


