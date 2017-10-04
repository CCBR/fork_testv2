library(rgl)
library(car)
library(shiny)

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
             
                #Sidebar to include the input file generator, which updates wil fil information
                #and file summary, once upload is completed. Action button generates pCOA plot
                sidebarLayout(
                  sidebarPanel(
                    fileInput("file","Upload the file", multiple=TRUE),
                    helpText("Default max. file size is 5MB"),
                    tags$hr(),
                    h5(helpText("Select the read.table parameters below")),
                    checkboxInput(inputId = 'header', label = 'Header', value = FALSE),
                    checkboxInput(inputId = "stringAsFactors", "stringAsFactors", FALSE),
                    br(),
                    radioButtons(inputId = 'sep', label = 'Separator', choices = c(Comma=',',Tab='\t', Space=''), 
                                selected = ','),
                    actionButton("goButton", "Generate pCOA Plot")
                  ),
                  mainPanel(
                    uiOutput("tb")
                  )
              )
            ),
            tabPanel("pCOA Plots",
                     rglwidgetOutput("plot",  width = 800, height = 600)
            )
  ) 
)
