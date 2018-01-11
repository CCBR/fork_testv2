library(rgl)
library(car)
library(shiny)
library("RColorBrewer")

#######################################################################################
###                                      NOTES                                      ###
#######################################################################################
#This code is written to take in the generated pCOA weighted unifrac values and generate
#a pCOA plot using the top three values. It will also allow users to upload a labels 
#document, which will allow for additional visualization of categorical labels. Users can 
#select color labels form a drop down list, generated from the names of column headers

#######################################################################################
###                                      Code                                      ###
#######################################################################################
fluidPage(
  
  #Create two navigation pages, 1) Input files | 2) pCOA Plots
  navbarPage("Microbime QC Testing",
    
             ##Create Page#1: Input File
             tabPanel("Input Files",
                      ###Sidebar includes the NOTE that files must be txt,
                      ###input files (data and labels), and exectuion button
                      fluidRow(
                        column(4,
                               helpText("NOTE: File should be a txt file"),
                          fileInput("file","Upload the pCOA_data_file"),
                          fileInput("file2","Upload the labels_file"),
                          actionButton("goButton", "Generate pCOA Plot")
                        ),
                        ###Main panel include summary of data files accepted
                        column(8,
                               uiOutput("table")
                        )
                      )
             ),
             ##Create Page#2: PCOA PLOTS
             tabPanel("pCOA Plots",
                      ###First Row contains the drop down selector of column names, generated
                      ###from data_labels file
                      fluidRow(
                        column(2,
                               uiOutput("choose_grouplabels")
                               ),
                        column(3,
                               checkboxGroupInput("inCheckboxGroup",
                                                  "Treatment Selection:",
                                                  c("Artificial Colony" = "artificial.colony",
                                                    "Robogut" = "robogut",
                                                    "Blank" = "Extraction.Blank",
                                                    "Study Sample" = "Study",
                                                    "Replicate" = "ExtractionReplicate")
                                                 )
                               ),
                        column(4,
                               radioButtons("radiolabelselect", label = h3("Sample ID Labels"),
                                            choices = list("No" = 1, "Yes" = 2), 
                                            selected = 1)
                               )
                      ),
                      ###Second Row contains the pCOA plot and legend of colors
                      fluidRow(
                        column(6,
                               rglwidgetOutput("plot",  width = 800, height = 800)
                               ),
                        column(5,
                               plotOutput("legend", width = 400, height=1000)
                               )
                      )
              ),
             ##Creat Page#3: Data Summary
            tabPanel("Data Summary",
                     
                     column(12, uiOutput('tabledata'))
                     
                     
                     
                     
                     
                     )
  )
)

