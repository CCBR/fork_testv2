library(rgl)
library(car)
library(shiny)
library("RColorBrewer")

#######################################################################################
###                                      NOTES                                      ###
#######################################################################################
##This code is written to take in the generated pCOA weighted unifrac values and generate
##a pCOA plot using the top three values. It will also allow users to upload a labels 
##document, which will allow for additional visualization of categorical labels.

#######################################################################################
###                                      Code                                      ###
#######################################################################################
fluidPage(
  
  ##Create two navigation pages, 1) Input files | 2) pCOA Plots
  navbarPage("Microbime QC Testing",
    tabPanel("Input Files",
                  
      #Sidebar to include the input files (data and labels) and generate a file summary. 
      #Once upload is completed summary is displayed and pCOA plot generated upon selection
      #of the action button.
      sidebarLayout(
        sidebarPanel(
          helpText("NOTE: File should be a txt file"),
          fileInput("file","Upload the pCOA_data_file"),
          
          helpText("NOTE: File should be a txt file with headers"),
          fileInput("file2","Upload the labels_file"),
          
          actionButton("goButton", "Generate pCOA Plot")
        ),
        mainPanel = (
          uiOutput("tb")
          )
      )
    ),
    tabPanel("pCOA Plots",
      fluidRow(
        column(3,
          actionButton("Button_Groups", "Color by Treatment Groups"), 
          br(),     
          actionButton("Button_AssayPlate", "Color by AssayPlate"),
          br(),
          actionButton("Button_Row", "Color by Row"),
          br(),
          actionButton("Button_QS", "Color by QS")
        ),
        column(4, offset=1,
          actionButton("Button_ExtractionBatch", "Color by ExtractionBatch"),
          br(),
          actionButton("Button_Row", "Color by Row"),
          br(),
          actionButton("Button_QS", "Color by QS"),
          br(),
          actionButton("Button_Row", "Color by Row"),
          br(),
          actionButton("Button_QS", "Color by QS")
        ),
        column(4,
          plotOutput("legend", width=300, height=300)     
        ),
      rglwidgetOutput("plot",  width = 1000, height = 800)
          
      )
    )
  )
)