# Rely on the 'WorldPhones' dataset in the datasets
# package (which generally comes preloaded).
library(datasets)

# Use a fluid Bootstrap layout
fluidPage(    
  
  # Give the page a title
  titlePanel("PRIO Grid count"),
  
  # Generate a row with a sidebar
  sidebarLayout(      
    
    # Define the sidebar with one input
    sidebarPanel(
      selectInput("side_b", "side_b:", 
                  choices=unique(prio.grids.count$side_b)),
      hr(),
      helpText("Data from UCDP GED")
    ),
    
    # Create a spot for the barplot
    mainPanel(
      plotOutput("areaPlot")  
    )
    
  )
)