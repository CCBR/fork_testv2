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
      #Once upload is completed summary is displayed and pCOA plot generated upon selection of the action button.
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
      h4("Choose Grouping Category"),
      fluidRow(
        column(2,
          actionButton("Button_TreatmentGroup", "Treatment Groups"), 
          br(),   
          actionButton("Button_ExtDate", "ExtDate"),
          br(),
          actionButton("Button_LibDate", "LibDate"),
          br(),
          actionButton("Button_ExtractionBatch", "ExtractionBatch"),
          br(),
          actionButton("Button_QIAsymph", "QIAsymph")
        ),
        column(2,
          actionButton("Button_AssayPlate", "AssayPlate"),
          br(),
          actionButton("Button_SeqRunID", "SeqRunID"),
          br(),
          actionButton("Button_Row", "Row"),
          br(),
          actionButton("Button_Column", "Column")
        ),
        column(2,
          actionButton("Button_LotReag", "Reagent Cartridge Lot"),
          br(),
          actionButton("Button_LotEnz", "Enzyme Cartridge Lot"),
          br(),
          actionButton("Button_LotATL", "ATL Lot")
        ),
        column(2,
          actionButton("Button_LotMGB", "MGB Lot"),
          br(),
          actionButton("Button_LotMM", "Master Mix Lot"),
          br(),
          actionButton("Button_LotPrimer", "Primer Plate Lot")
        )
      ),
      fluidRow(
        column(6,
          rglwidgetOutput("plot",  width = 800, height = 800)
        ),
        column(5,
          plotOutput("legend", height=800)
        )
      )
    )
  )
)