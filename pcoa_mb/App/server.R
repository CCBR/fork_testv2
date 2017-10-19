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

function(input,output){
  
  # Takes the input file of pCOA data, saving it to the data_vals matrix AND an input file of categories
  # saving it to the data_labels matrix
  data_vals <- reactive({
      file <- input$file
      if (is.null(file))
        return(NULL)
      pcoa_full <- read.table(file=input$file$datapath)
  }) 
  data_labels <- reactive({
    file2 <- input$file2
    if (is.null(file2))
      return(NULL)
      pcoa_labs <- read.table(file=input$file2$datapath)
  })  
  
  #Display the summary for the file information provided by the user
  output$filepcoa <- renderTable({
      if(is.null(data_vals())){return ()}
      input$file
  })
  output$tb <- renderUI({
    if(is.null(data_vals())){return()}
    else
      tabsetPanel(tabPanel("File Summary", tableOutput("filepcoa")))
  })

  #When the active button has been selected, generates a pCOA plot for the user to manipulate
  observeEvent(input$goButton, {
      
      #Create palette of colors
      palette(c(brewer.pal(n=12, name = "Paired"),brewer.pal(n=12, name = "Set3"),brewer.pal(n=11, name = "Spectral")))
      
      #Assign top three pCOA values to plot
      pc1 <- data_vals()[,2]
      pc2 <- data_vals()[,3]
      pc3 <- data_vals()[,4]
      
      #Assign labels to the plot, from input
      pcoa_labs <- data_labels()
      
      #Change Output based on User Action Button initiation
      observeEvent(input$Button_Groups, {
        output$plot <- renderRglwidget({
          open3d(useNULL=TRUE)
          scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = pcoa_labs$V3, pch=5, surface.col = palette(), cex=5,
            axis.col = c("white", "white", "white"), bg="black", colkey=list(side=1,length=.5, labels=pcoa_labs$V3))
          par3d(mouseMode = "trackball")
          rglwidget()
        })
        output$legend <- renderPlot({
          par(pin=c(3,3))
          plot(x=1,y=NULL,type="n",xaxt="n",yaxt="n",ylab="",xlab="",bty="n")
          legend("topleft",legend=unique(pcoa_labs$V3),col=palette(),pch=16, cex=1.5)
        })
      })
      observeEvent(input$Button_AssayPlate, {
        output$plot <- renderRglwidget({
          open3d(useNULL=TRUE)
          scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = pcoa_labs$V5, pch=5, surface.col = palette(), cex=5,
            axis.col = c("white", "white", "white"), bg="black")
          par3d(mouseMode = "trackball")
          rglwidget()
        })
        output$legend <- renderPlot({
          par(pin=c(3,3))
          plot(x=1,y=NULL,type="n",xaxt="n",yaxt="n",ylab="",xlab="",bty="n")
          legend("topleft",legend=unique(pcoa_labs$V5),col=palette(),pch=16, cex=1.5)
        })
      })
      observeEvent(input$Button_ExtractionBatch, {
        output$plot <- renderRglwidget({
          open3d(useNULL=TRUE)
          scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = pcoa_labs$V6, pch=5, surface.col = palette(), cex=5,
            axis.col = c("white", "white", "white"), bg="black")
          par3d(mouseMode = "trackball")
          rglwidget()
       })
        output$legend <- renderPlot({
          par(pin=c(3,3))
          plot(x=1,y=NULL,type="n",xaxt="n",yaxt="n",ylab="",xlab="",bty="n")
          legend("topleft",legend=unique(pcoa_labs$V6),col=palette(),pch=16, cex=1.5)
        })
      })
      observeEvent(input$Button_Row, {
        output$plot <- renderRglwidget({
          open3d(useNULL=TRUE)
          scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = pcoa_labs$V8, pch=5, surface.col = palette(), cex=5,
            axis.col = c("white", "white", "white"), bg="black")
          par3d(mouseMode = "trackball")
          rglwidget()
        })
        output$legend <- renderPlot({
          par(pin=c(3,3))
          plot(x=1,y=NULL,type="n",xaxt="n",yaxt="n",ylab="",xlab="",bty="n")
          legend("topleft",legend=unique(pcoa_labs$V8),col=palette(),pch=16, cex=1.5)
        })
      })
      observeEvent(input$Button_QS, {
        output$plot <- renderRglwidget({
          open3d(useNULL=TRUE)
          scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = as.factor(pcoa_labs$V16), pch=5, surface.col = palette(), cex=5,
            axis.col = c("white", "white", "white"), bg="black")
          par3d(mouseMode = "trackball")
          rglwidget()
        })
        output$legend <- renderPlot({
          par(pin=c(3,3))
          plot(x=1,y=NULL,type="n",xaxt="n",yaxt="n",ylab="",xlab="",bty="n")
          legend("topleft",legend=unique(pcoa_labs$V16),col=palette(),pch=16, cex=1.5)
        })
        
    })
  })
}