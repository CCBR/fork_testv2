library(rgl)
library(car)
library(shiny)
library(shinyjs)
library(shinydashboard)
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



#######################################################################################
#################################HEADER INFORMATION####################################

#Create header to display, and disable the sidebar
header <- dashboardHeader(title = "Microbiome QC Analysis")


#######################################################################################
#################################SideBar INFORMATION####################################

##Create the sidebard with three items
sidebar <- dashboardSidebar(
 sidebarMenu(
  menuItem("File Uploads", tabName = "fileuploads"),
  menuItem("pCOA Plots", tabName="pcoaplots"),
  menuItem("Table Summary", tabName="datasummary")
  )
 )

#######################################################################################
#################################MainBody INFORMATION####################################

##Create the Main body information for File Uploads
###First data box includes all text upload information
fcol1 <- fluidRow(
  column(12,
         fileInput("file","Upload the pCOA File"),
         fileInput("file2","Upload the Labels"),
         actionButton("goButton", "Generate pCOA Plot" 
                      #style="color: #fff; background-color: #337ab7; border-color: #2e6da4"
                      )
         )
  )
##Second data box includes summary of file information
fcol2 <- fluidRow(
 column(12,
        uiOutput("table")
 )
)
##Third data box includes a confirmation that the action button has generated a plot
fcol3 <- fluidRow(
 column(12,
        hidden(
         verbatimTextOutput("text"))
        )
)

#Generate Boxes for text submission, and data table generation
box1 <- box(title = "Upload Text Files", width=4, status="primary", 
            solidHeader = TRUE, fcol1)
box2 <- box(title = "File Upload Summary", width=8, status="primary", 
            solidHeader = TRUE, fcol2)
box3 <- box(title = "Confirmation", width=8, status="primary", 
            solidHeader = TRUE, fcol3)

##Create the Main body information for the pCOA plot and filtering data
##4: COlor Data by group selection, #5: ill Label data
fcol4 <- fluidRow(
 column(5, uiOutput("choose_grouplabels"))
 )

###5: Select the Sample labels to choose from
fcol5 <- fluidRow(
 column(5,uiOutput("choose_samplelabels"))
 )

###6: Determines the filters to visualize
fcol6 <- fluidRow(
 column(7,
        checkboxGroupInput("inCheckboxGroup",
                           "Treatment Selection:",
                           c("Artificial Colony" = "artificial.colony",
                             "Robogut" = "robogut",
                             "Blank" = "Extraction.Blank",
                             "Study Sample" = "Study",
                             "Replicate" = "ExtractionReplicate"))
        )
 )
###7: Creates the PCOA Plot
fcol7 <- fluidRow(
 column(7, rglwidgetOutput("plot", width=700))
)

###8: Creates the Legend
fcol8 <- fluidRow(
 column(5, plotOutput("legend", width=400, height=1000))
 )

#Generate Boxes for the filtering and plot generation tools
box456 <- fluidRow(
 column(5,
        box(title = "Coloring Tools", width=NULL, status="primary", collapsible = TRUE,
            solidHeader = TRUE, fcol4),
        box(title = "Labeling Tools", width=NULL, status="primary", collapsible = TRUE,
            solidHeader = TRUE, fcol5)
        ),
 column(7,
        box(title="FIltering Tools", width=NULL, status="primary", collapsible = TRUE,
            solidHeader = TRUE, fcol6)
        )
 )
box78 <- fluidRow(
 column(8,
        box(title = "pCOA Plots", width=NULL, status="primary", collapsible = TRUE,
            solidHeader = TRUE, fcol7)
        ),
 column(4,
        box(title="Legend",width=NULL, status="primary", collapsible = TRUE,
            solidHeader = TRUE, fcol8)
 )
)

##Create the Data Table Summary information
##Will COlor Data
fcol9 <- fluidRow(
 column(11, uiOutput('tabledata'))
)

#Generate Boxes for text submission, and data table generation
box9 <- fluidRow(
 column(12,
        box(title = "Data Summary", width=NULL, status="primary", collapsible = TRUE,
            solidHeader = TRUE, fcol9))
)


##Combine all body information, and assign outputs to each appropriate tab 
body <- dashboardBody(
 tabItems(
  tabItem(tabName="fileuploads",
          box1, 
          box2,
          box3
          ),
  tabItem(tabName="pcoaplots",
          box456,
          box78),
  tabItem(tabName="datasummary",
          box9
          )
 )
)
dashboardPage(header,sidebar,body)
 
 

