library(rgl)
library(car)
library(shiny)
library("RColorBrewer")
library(leaflet)

#######################################################################################
###                                      NOTES                                      ###
#######################################################################################
##This code is written to take in the generated pCOA weighted unifrac values and generate
##a pCOA plot using the top three values. It will also allow users to upload a labels 
##document, which will allow for additional visualization of categorical labels.

#######################################################################################
###                                      Code                                      ###
#######################################################################################

function(input,output, session){
  
  ########################################################################
  #############################Input Files Page###########################
  
  # Takes the input file of pCOA data, saving it to the data_vals matrix 
  data_vals <- reactive({
    file <- input$file
    if (is.null(file))
      return(NULL)
    read.table(file=input$file$datapath)
  })
  
  # Takes the input file of categories labels, saving it to the data_labels matrix
  data_labels <- reactive({
    file2 <- input$file2
    if (is.null(file2))
      return(NULL)
    read.table(file=input$file2$datapath, header=TRUE, colClasses = "factor")
  })  
  
  #Display the summary for the PCOA and Lables files provided by the user
  output$filepcoa <- renderTable({
    if(is.null(data_vals())){return ()}
    input$file
  })
  output$filelabels <- renderTable({
    if(is.null(data_vals())){return ()}
    input$file2
  })
  output$table <- renderUI({
    if(is.null(data_vals())){return()}
    else
      tabsetPanel(
        tabPanel("File Input Summary", tableOutput("filepcoa"),tableOutput("filelabels"))
      )
  })
  
  ########################################################################
  #############################pCOA Plots Page###########################
  #Create palette of colors
  palette(c(brewer.pal(n=12, name = "Paired"),
            brewer.pal(n=12, name = "Set3"),
            brewer.pal(n=11, name = "Spectral")))
  
  #Create Treatment Group options
  treat_types <- c("AC" = "artificial.colony", 
                   "RG" = "robogut", 
                   "EB" = "Extraction.Blank",
                   "Study" = "Study", 
                   "Replicate" = "Extraction.Replicate")
  
  #Create dropdown list from the column names of the data_lables file, shown to user
  #Create checkboxes for user to select treatment type to show
  observe({
    req(input$file2)
    dsnames <- names(data_labels())
    cb_options <- list()
    cb_options[dsnames] <- dsnames
    output$choose_grouplabels<- renderUI({
      selectInput("grouplabels", "Data set", cb_options)
    })
    updateCheckboxGroupInput(session, "inCheckboxGroup", "Treatment Selection:",
                               choices=treat_types,
                               selected=treat_types)
   })
  
  #Generate the data and labels for generate of the PCOA plot
  observe({
    #If data files have been inputted correctly, create database of labels and PCOA information
    if(is.null(input$file) | is.null(input$file2)) 
      return()
    else{
      
      #Create a subset of the full dataset
      combined_data <- cbind(data_vals(), data_labels())
   
      #If treatment group checkboxes are chosen, select only treatment groups
      treatselect <- input$inCheckboxGroup
      full_data <- subset(combined_data, TreatmentGroup %in% treatselect)
     
      #Create the color grouping by the label selected. If none are selected return TreatmentGroup    
      if(is.null(input$grouplabels)) {
        group_select <- full_data[,"TreatmentGroup"]
      }
      else{
        group_select <- full_data[,input$grouplabels]
      }
      
      #Assign top three pCOA values to plot
      pc1 <- full_data[,2]
      pc2 <- full_data[,3]
      pc3 <- full_data[,4]
    
      #Once the Go button is selected on INPUT FILES page, plot and legend are generated and updated
      #based on user input of DataSet and Treatement Selection
      observeEvent(input$goButton,{
        
        #Return the PCOA plot, with the grouping of colors by the input group labels
        output$plot <- renderRglwidget({
          scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = group_select, pch=5, surface.col = palette(), cex=5,
                    axis.col = c("white", "white", "white"), bg="black")
          par3d(mouseMode = "trackball")
          rglwidget()
        })
        
        #Return the PCOA legend, with the grouping of colors by the input group labels
        output$legend <- renderPlot({
          unilabs <- sort(unique(group_select))
          plot.new()
          legend("topleft",title="Color Legend",legend=unilabs,col=palette(),pch=16, cex=1.5)
        })
      })
    }
  })
}