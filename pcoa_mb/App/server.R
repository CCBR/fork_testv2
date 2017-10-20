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
      pcoa_labs <- read.table(file=input$file2$datapath, header=TRUE, colClasses = "factor")
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
      
    #Change Output based on User Action Button initiation. Groups by chosen characteristic, sorts and colors unique
    #factors and print outs legend to webbrowser
    
    ##Treatement Groups
    observeEvent(input$Button_TreatmentGroup, {
      group_select = pcoa_labs$TreatmentGroup
      output$plot <- renderRglwidget({
        open3d(useNULL=TRUE)
        scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = group_select, pch=5, surface.col = palette(), cex=5,
                  axis.col = c("white", "white", "white"), bg="black")
        par3d(mouseMode = "trackball")
        rglwidget()
      })
      output$legend <- renderPlot({
        unilabs <- sort(unique(group_select))
        plot.new()
        legend("topleft",title="Color Legend",legend=unilabs,col=palette(),pch=16, cex=1.5)
      })
    })
    ##Extraction Date
    observeEvent(input$Button_ExtDate, {
      group_select = pcoa_labs$ExtDate
      output$plot <- renderRglwidget({
        open3d(useNULL=TRUE)
        scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = group_select, pch=5, surface.col = palette(), cex=5,
                  axis.col = c("white", "white", "white"), bg="black")
        par3d(mouseMode = "trackball")
        rglwidget()
      })
      output$legend <- renderPlot({
        unilabs <- sort(unique(group_select))
        plot.new()
        legend("topleft",title="Color Legend",legend=unilabs,col=palette(),pch=16, cex=1.5)
      })
    })  
    
    ##Library Prep Date
    observeEvent(input$Button_LibDate, {
      group_select = pcoa_labs$LibDate
      output$plot <- renderRglwidget({
        open3d(useNULL=TRUE)
        scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = group_select, pch=5, surface.col = palette(), cex=5,
                  axis.col = c("white", "white", "white"), bg="black")
        par3d(mouseMode = "trackball")
        rglwidget()
      })
      output$legend <- renderPlot({
        unilabs <- sort(unique(group_select))
        plot.new()
        legend("topleft",title="Color Legend",legend=unilabs,col=palette(),pch=16, cex=1.5)
      })
    })
    
    ##Extraction Batch
    observeEvent(input$Button_ExtractionBatch, {
      group_select = pcoa_labs$ExtractionBatch
      output$plot <- renderRglwidget({
        open3d(useNULL=TRUE)
        scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = group_select, pch=5, surface.col = palette(), cex=5,
                  axis.col = c("white", "white", "white"), bg="black")
        par3d(mouseMode = "trackball")
        rglwidget()
      })
      output$legend <- renderPlot({
        unilabs <- sort(unique(group_select))
        plot.new()
        legend("topleft",title="Color Legend",legend=unilabs,col=palette(),pch=16, cex=1.5)
      })
    })
    
    #QIAsymphony
    observeEvent(input$Button_QIAsymph, {
      group_select = pcoa_labs$QIAsymph
      output$plot <- renderRglwidget({
        open3d(useNULL=TRUE)
        scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = group_select, pch=5, surface.col = palette(), cex=5,
                  axis.col = c("white", "white", "white"), bg="black")
        par3d(mouseMode = "trackball")
        rglwidget()
      })
      output$legend <- renderPlot({
        unilabs <- sort(unique(group_select))
        plot.new()
        legend("topleft",title="Color Legend",legend=unilabs,col=palette(),pch=16, cex=1.5)
      })  
    })
    
    ##AssayPlate
    observeEvent(input$Button_AssayPlate, {
      group_select = pcoa_labs$AssayPlate
      output$plot <- renderRglwidget({
        open3d(useNULL=TRUE)
        scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = group_select, pch=5, surface.col = palette(), cex=5,
                  axis.col = c("white", "white", "white"), bg="black")
        par3d(mouseMode = "trackball")
        rglwidget()
      })
      output$legend <- renderPlot({
        unilabs <- sort(unique(group_select))
        plot.new()
        legend("topleft",title="Color Legend",legend=unilabs,col=palette(),pch=16, cex=1.5)
      })
    })
    
    #Sequence Run ID
    observeEvent(input$Button_SeqRunID, {
      group_select = pcoa_labs$SeqRunID
      output$plot <- renderRglwidget({
        open3d(useNULL=TRUE)
        scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = group_select, pch=5, surface.col = palette(), cex=5,
                  axis.col = c("white", "white", "white"), bg="black")
        par3d(mouseMode = "trackball")
        rglwidget()
      })
      output$legend <- renderPlot({
        unilabs <- sort(unique(group_select))
        plot.new()
        legend("topleft",title="Color Legend",legend=unilabs,col=palette(),pch=16, cex=1.5)
      })
    })
    
    #Row
    observeEvent(input$Button_Row, {
      group_select = pcoa_labs$Row
      output$plot <- renderRglwidget({
        open3d(useNULL=TRUE)
        scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = group_select, pch=5, surface.col = palette(), cex=5,
                  axis.col = c("white", "white", "white"), bg="black")
        par3d(mouseMode = "trackball")
        rglwidget()
      })
      output$legend <- renderPlot({
        unilabs <- sort(unique(group_select))
        plot.new()
        legend("topleft",title="Color Legend",legend=unilabs,col=palette(),pch=16, cex=1.5)
      })
    })
    
    ##Column
    observeEvent(input$Button_Column, {
      group_select = pcoa_labs$Column
      output$plot <- renderRglwidget({
        open3d(useNULL=TRUE)
        scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = group_select, pch=5, surface.col = palette(), cex=5,
                  axis.col = c("white", "white", "white"), bg="black")
        par3d(mouseMode = "trackball")
        rglwidget()
      })
      output$legend <- renderPlot({
        unilabs <- sort(unique(group_select))
        plot.new()
        legend("topleft",title="Color Legend",legend=unilabs,col=palette(),pch=16, cex=1.5)
      })
    })  
    
    ##Reagent Lot
    observeEvent(input$Button_LotReag, {
      group_select = pcoa_labs$Lot_Reag
      output$plot <- renderRglwidget({
        open3d(useNULL=TRUE)
        scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = group_select, pch=5, surface.col = palette(), cex=5,
                  axis.col = c("white", "white", "white"), bg="black")
        par3d(mouseMode = "trackball")
        rglwidget()
      })
      output$legend <- renderPlot({
        unilabs <- sort(unique(group_select))
        plot.new()
        legend("topleft",title="Color Legend",legend=unilabs,col=palette(),pch=16, cex=1.5)
      })
    })  
    
    ##Enzyme Lot
    observeEvent(input$Button_LotEnz, {
      group_select = pcoa_labs$Lot_Enz
      output$plot <- renderRglwidget({
        open3d(useNULL=TRUE)
        scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = group_select, pch=5, surface.col = palette(), cex=5,
                  axis.col = c("white", "white", "white"), bg="black")
        par3d(mouseMode = "trackball")
        rglwidget()
      })
      output$legend <- renderPlot({
        unilabs <- sort(unique(group_select))
        plot.new()
        legend("topleft",title="Color Legend",legend=unilabs,col=palette(),pch=16, cex=1.5)
      })
    })  
    
    ##LotATL
    observeEvent(input$Button_LotATL, {
      group_select = pcoa_labs$LotATL
      output$plot <- renderRglwidget({
        open3d(useNULL=TRUE)
        scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = group_select, pch=5, surface.col = palette(), cex=5,
                  axis.col = c("white", "white", "white"), bg="black")
        par3d(mouseMode = "trackball")
        rglwidget()
      })
      output$legend <- renderPlot({
        unilabs <- sort(unique(group_select))
        plot.new()
        legend("topleft",title="Color Legend",legend=unilabs,col=palette(),pch=16, cex=1.5)
      })
    })
    
    ##MGB Lot
    observeEvent(input$Button_LotMGB, {
      group_select = pcoa_labs$Lot_MGB
      output$plot <- renderRglwidget({
        open3d(useNULL=TRUE)
        scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = group_select, pch=5, surface.col = palette(), cex=5,
                  axis.col = c("white", "white", "white"), bg="black")
        par3d(mouseMode = "trackball")
        rglwidget()
      })
      output$legend <- renderPlot({
        unilabs <- sort(unique(group_select))
        plot.new()
        legend("topleft",title="Color Legend",legend=unilabs,col=palette(),pch=16, cex=1.5)
      })
    })
    
    ##Master Mix Lot
    observeEvent(input$Button_LotMM, {
      group_select = pcoa_labs$Lot_MM
      output$plot <- renderRglwidget({
        open3d(useNULL=TRUE)
        scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = group_select, pch=5, surface.col = palette(), cex=5,
                  axis.col = c("white", "white", "white"), bg="black")
        par3d(mouseMode = "trackball")
        rglwidget()
      })
      output$legend <- renderPlot({
        unilabs <- sort(unique(group_select))
        plot.new()
        legend("topleft",title="Color Legend",legend=unilabs,col=palette(),pch=16, cex=1.5)
      })
    })
    
    ##Primer Lot
    observeEvent(input$Button_LotPrimer, {
      group_select = pcoa_labs$Lot_Primer
      output$plot <- renderRglwidget({
        open3d(useNULL=TRUE)
        scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = group_select, pch=5, surface.col = palette(), cex=5,
                  axis.col = c("white", "white", "white"), bg="black")
        par3d(mouseMode = "trackball")
        rglwidget()
      })
      output$legend <- renderPlot({
        unilabs <- sort(unique(group_select))
        plot.new()
        legend("topleft",title="Color Legend",legend=unilabs,col=palette(),pch=16, cex=1.5)
      })
    })

  })
}