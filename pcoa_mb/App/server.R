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

    #Skip the first 9 lines of the PCOA data table, read in the table. 
    #Removes the last two lines that includes the Biplot and Site data and includes top 3 pCOA data 
    #Updates all col classes to numeric for evaluation
    #Renames the col1 to StudyID, col2 to pcOA1, col3 to pCOA2, col4 to pCOA3 for later matching
    
    data_val_ori <- read.table(skip=9,fill=TRUE, file=input$file$datapath)
    colschoose <- dim(data_val_ori)[1]-2
      data_clean <- data_val_ori[1:colschoose,1:4]
    data_clean$V2 <- as.numeric(data_clean$V2)
    names(data_clean)[1] <- "StudyID"
      names(data_clean)[2] <- "pCOA1"
      names(data_clean)[3] <- "pCOA2"
      names(data_clean)[4] <- "pCOA3"
    return(data_clean)
  })
  
  # Takes the input file, with headers, of data labels, saving it to the data_labels matrix
  data_labels <- reactive({
    file2 <- input$file2
    if (is.null(file2))
      return(NULL)
    read.table(fill=TRUE,file=input$file2$datapath, header=TRUE, colClasses = "factor")
  })  
  
  #Display the summary for the PCOA and Lables files provided by the user
  #Each file becomes separate row of summary information to view
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
  
  output$filedata <- renderTable({
    if(is.null(data_labels())){return ()}
    data_labels()
  })
  
  output$tabledata <- renderUI({
    if(is.null(data_labels())){return()}
    else
      tabsetPanel(
        tabPanel("File Input Summary", tableOutput("filedata"))
      )
  })
  
  ########################################################################
  #############################pCOA Plots Page###########################
  #Create palette of colors
  palette(c(brewer.pal(n=12, name = "Set3"),
            brewer.pal(n=12, name = "Paired"),
            brewer.pal(n=11, name = "Spectral"),
            brewer.pal(n=7, name = "Accent")
            ))
  
  #Create Treatment Group options
  treat_types <- c("Artificial Colony" = "artificial.colony", 
                   "Robogut" = "robogut", 
                   "Blank" = "Extraction.Blank",
                   "Study Sample" = "Study", 
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
  
  #Create a radio button that updates whether or not to display the SampleID label name
  observe({
    updateRadioButtons(session, "radiolabelselect",
                       label = "Sample ID Labels",
                       choices = list("No" = 1, "Yes" = 2), 
                       selected = 1)
  })
    
  #PCOA plot generation
  observe({
    #If data files have been inputted correctly, create database of labels and PCOA information
    if(is.null(input$file) | is.null(input$file2)) 
      return()
    
    else{
      
      #Create a subset of the full dataset
      combined_data <- merge.data.frame(data_vals(), data_labels(), by="StudyID")

      #Deterine the treatment group based on the checkboxes selected
      #Create dataset with only specified treatment groups
      treatselect <- input$inCheckboxGroup
      full_data <- subset(combined_data, TreatmentGroup %in% treatselect)
     
      #Display the Combined Data Table in the Data Table tab 
      output$filedata <- renderTable({
        if(is.null(full_data)){return ()}
        full_data
      })
      
      output$tabledata <- renderUI({
        if(is.null(full_data)){return()}
        else
          tabsetPanel(
            tabPanel("Current Data Summary", tableOutput("filedata"))
          )
      })
      
      
      #Determine the label status based on the radio button selected
      labelselect <- input$radiolabelselect
      
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
          #Checks the length of group factors to be >0; displays error message if false
          if((length(group_select))==0) {
            stop(print("No Samples Selected in Treatment Selection for plot"))
          }
          
          else if(labelselect==1){
            scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, 
                      groups = group_select, pch=5, surface.col = palette(), cex=5,
                      axis.col = c("white", "white", "white"), bg="black"
                      )
            par3d(mouseMode = "trackball")
            rglwidget()
          }
          
          else {
            scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, 
                      groups = group_select, pch=5, surface.col = palette(), cex=5,
                      axis.col = c("white", "white", "white"), bg="black", 
                      labels=full_data$SampleName, id.n=nrow(full_data)
            )
            par3d(mouseMode = "trackball")
            rglwidget()
          }
        })
        
        #Return the PCOA legend, with the grouping of colors by the input group labels
        output$legend <- renderPlot({
          #Checks the length of group factors to be >0; displays error message if false
          if((length(group_select))==0) stop(print("No Samples Selected in Treatment Selection for legend"))
          unilabs <- sort(unique(group_select))
          plot.new()
          legend("topleft",title="Color Legend",legend=unilabs,col=palette(),pch=16, cex=1.5)
        })
        
        
      })
    }
  })
}