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
 
 #Takes the input file of pCOA data, saving it to the data_vals matrix 
 data_vals <- reactive({
  file <- input$file
  if (is.null(file))
   return(NULL)
  
  #Skip the first 9 lines of the PCOA data table, read in the table. 
  #Removes the last two lines that includes the Biplot and Site data 
  #Chooses the sample ID and top 3 pCOA values 
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
 
 #Takes the input file, with headers, of data labels, saving it to the data_labels matrix
 data_labels <- reactive({
  file2 <- input$file2
  if (is.null(file2)) return(NULL)
  read.table(fill=TRUE,file=input$file2$datapath, header=TRUE, colClasses = "factor")
 })  
 
 #Display the summary for the PCOA and Lables files provided by the user
 #Each file becomes separate row of summary information to view
 output$filepcoa <- renderTable({
  if(is.null(data_vals())) return ()
  input$file
 })
 output$filelabels <- renderTable({
  if(is.null(data_vals())) return ()
  input$file2
 })
 output$table <- renderUI({
  if(is.null(data_vals())) return()
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
 
 #Displays a confirmation message to user to select the pCOA Plots tab
 observeEvent(input$goButton,{
  output$text <- renderText({
   "Upload Completed - Select pCOA Plots Tab to view"})  
 })
 
 ########################################################################
 #############################pCOA Plots Page###########################
 #Create palette of colors
 palette(c(brewer.pal(n=12, name = "Set3"), brewer.pal(n=12, name = "Paired"),
           brewer.pal(n=11, name = "Spectral"), brewer.pal(n=7, name = "Accent"),
           brewer.pal(n=12, name = "Set3"), brewer.pal(n=12, name = "Paired"),
           brewer.pal(n=11, name = "Spectral"), brewer.pal(n=7, name = "Accent"),
           brewer.pal(n=12, name = "Set3"), brewer.pal(n=12, name = "Paired"),
           brewer.pal(n=11, name = "Spectral"), brewer.pal(n=7, name = "Accent"),
           brewer.pal(n=12, name = "Set3"), brewer.pal(n=12, name = "Paired"),
           brewer.pal(n=11, name = "Spectral"), brewer.pal(n=7, name = "Accent"),
           brewer.pal(n=12, name = "Set3"), brewer.pal(n=12, name = "Paired"),
           brewer.pal(n=11, name = "Spectral"), brewer.pal(n=7, name = "Accent"),
           brewer.pal(n=12, name = "Set3"), brewer.pal(n=12, name = "Paired"),
           brewer.pal(n=11, name = "Spectral"), brewer.pal(n=7, name = "Accent"),
           brewer.pal(n=12, name = "Set3"), brewer.pal(n=12, name = "Paired"),
           brewer.pal(n=11, name = "Spectral"), brewer.pal(n=7, name = "Accent"),
           brewer.pal(n=12, name = "Set3"), brewer.pal(n=12, name = "Paired"),
           brewer.pal(n=11, name = "Spectral"), brewer.pal(n=7, name = "Accent"),
           brewer.pal(n=12, name = "Set3"), brewer.pal(n=12, name = "Paired"),
           brewer.pal(n=11, name = "Spectral"), brewer.pal(n=7, name = "Accent")
 ))
 
 #Create dropdown list from the column names of the data_lables file, shown to user
 observe({
  req(input$file2)
  dsnames <- names(data_labels())
  cb_options <- list()
  cb_options[dsnames] <- dsnames
  output$choose_colorlabels<- renderUI({
   selectInput("colorlabels", "Data set", cb_options)
  })
 })
 
 #Create a radio button that updates whether or not to display the SampleID label name
 observe({
  req(input$file2)
  dsnames <- c(names(data_labels()), "NONE")
  cb_options <- list()
  cb_options[dsnames] <- dsnames
  output$choose_samplelabels<- renderUI({
   radioButtons("samplelabels", "ID Labels", cb_options, selected = "NONE")
  })
 })
 
 #Create Filters, and subsequent radio buttons for user to filter out sample by category
 ##Filter Level 1
  observe({
   req(input$file2)
   dsnames <- names(data_labels())
   cb_options <- list()
   cb_options[dsnames] <- dsnames
   output$choose_filt1<- renderUI({
    selectInput("filt1", "Filter Level 1", cb_options)
   })
  })
  observe({
   filt1_data <- data_labels()[,input$filt1]
   filt1_uni <- unique(filt1_data)
   output$inCheckboxGroup1 <- renderUI({
    checkboxGroupInput("inCheckboxGroup1", "Filter Level 1 Options:",
                       choices=filt1_uni, selected=filt1_uni)
   })
  })
 
 ##Filter Level 2
  observe({
   req(input$file2)
   dsnames <- names(data_labels())
   cb_options <- list()
   cb_options[dsnames] <- dsnames
   choice1 <- input$filt1
   cb_options <- c(setdiff(cb_options,choice1))
   output$choose_filt2<- renderUI({
    selectInput("filt2", "Filter Level 2", cb_options)
   })
  })
  observe({
   filt1sub <- input$inCheckboxGroup1
   filt1_data <- data_labels()[data_labels()[,input$filt1] %in% filt1sub,]
   filt2_data <- filt1_data[,input$filt2]
   filt2_uni <- unique(filt2_data)
   output$inCheckboxGroup2 <- renderUI({
    checkboxGroupInput("inCheckboxGroup2", "Filter Level 2 Options:",
                       choices=filt2_uni,selected=filt2_uni)
   })
  })
 
 ##Filter Level 3
  observe({
   req(input$file2)
   dsnames <- names(data_labels())
   cb_options <- list()
   cb_options[dsnames] <- dsnames
   choice1 <- input$filt1
   choice2 <- input$filt2
   cb_options <- c(setdiff(cb_options,c(choice1, choice2)))
   output$choose_filt3<- renderUI({
    selectInput("filt3", "Filter Level 3", cb_options)
   })
  })
  observe({
   filt1sub <- input$inCheckboxGroup1
   filt1_data <- data_labels()[data_labels()[,input$filt1] %in% filt1sub,]
   filt2sub <- input$inCheckboxGroup2
   filt2_data <- filt1_data[filt1_data[,input$filt2] %in% filt2sub,]
   filt3_data <- filt2_data[,input$filt3]
   filt3_uni <- unique(filt3_data)
   output$inCheckboxGroup3 <- renderUI({
    checkboxGroupInput("inCheckboxGroup3", "Filter Level 3 Options:",
                       choices=filt3_uni,
                       selected=filt3_uni)
   })
  })
 
 #Create PCOA plot
 observe({
  ##If data files have been inputted correctly, create database of labels and PCOA information
  if(is.null(input$file) | is.null(input$file2)) 
   return()
  
  else{
   
   ###Create a subset of the full dataset
   combined_data <- merge.data.frame(data_vals(), data_labels(), by="StudyID")
   
   ###Deterine the first filter group based on the drop down selected
   ###Determine the subgroup by the checkboxes selected
   ###Create dataset with only specified treatment groups
   filt1sub <- input$inCheckboxGroup1
   filt2sub <- input$inCheckboxGroup2
   filt3sub <- input$inCheckboxGroup3
   if(is.null(filt1sub)) {
    full_data<-combined_data
    }else{
    full_data1 = combined_data[combined_data[,input$filt1] %in% filt1sub,]
    full_data2 = full_data1[full_data1[,input$filt2] %in% filt2sub,]
    full_data = full_data2[full_data2[,input$filt3] %in% filt3sub,]
   }
   
   ###Determine the label status based on the radio button selected
   labelselect <- input$radiolabelselect
   
   ###Create the color grouping by the label selected. 
   ###If none are selected return TreatmentGroup    
   if(is.null(input$colorlabels)) {
    group_select <- full_data[,5]
   }
   else{
    group_select <- full_data[,input$colorlabels]
   }
   
   ###Display the Combined Data Table in the Data Table tab 
   output$filedata <- renderTable({
    if(is.null(full_data)){return ()}
    full_data
   })
   
   output$tabledata <- renderUI({
    if(is.null(full_data)){return()}
    else
     tableOutput("filedata")
   })
   
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
     
     else if(input$samplelabels=="NONE"){
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
                labels=full_data[,input$samplelabels], id.n=nrow(full_data)
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