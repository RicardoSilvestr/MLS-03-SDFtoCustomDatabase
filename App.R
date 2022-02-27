library("ChemmineR")
library(shiny)
library(DT)
library("Hmisc")
library("MALDIquant")
library("ChemmineR")
library(readr)
library(shiny)
library(shinydashboard)
library(Rdisop)

options(shiny.maxRequestSize = 40*1024^2)
Iontype <- c("[Mn+X]+","[Mn-H+X]+","[Mn-2H+X]+","[Mn-3H+X]+", "[M5-H2O-2H+3Na]+","[M5-2H2O-4H+4Na+K]+","[M5-H2O-4H+4Na+K]+","[M6-2H2O-4H+4Na+K]+","[M6-6H+nH2O+3Fe+O]+","[M7-6H+3Fe+O]+","M+","[M+H]+","[M+X]+","[M+H-CH4]+","[M6-6H+3Fe+O]+")
modif <- c("(H+).(Na+).(K+).([63Cu]+).([65Cu]+).(NH4+).(H+).(Na+).(K+).(CF3CO2H)(K+).(C3F9C3O6H2)(K2+)","(Na+)2.(K+)2.(Na)+(K)+","(Na+)3.(K+)3.(Na+)3K+.Na+(K+)2", "(Na+)4.(K+)4.(Na+)2(K+)2.(Na+)(K+)3.(Na+)3(K+)","(Na+)3","(Na+)4(K+)","(Na+)4(K+)","(Na+)4(K+)","(H2O)(Fe)3(O+)","(Fe)3(O+)","(+)","(H+).(Na+).(K+).(CH3CN)(Na+).(NH4+).(H2)++","(H+).(Na+).(K+).(CH3CN)(Na+).(CH3CN)(H+).(CH3CN)(NH4+).[120Sn](+)","H(C-1H-4)(+)","(Fe3OH-6)(+)")
ref <-as.data.frame(cbind(Iontype,modif))

ui <- fluidPage(
  titlePanel("Scifinder Custom database"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", NULL, buttonLabel = "Upload...", multiple = FALSE),textInput("filename", "File Name", ""),
      helpText("Default max. file size is 40MB"),
      checkboxGroupInput("comp_type", "Ion ", choices = ref[,1]),
      actionButton(
        inputId = "submit_loc",
        label = "Submit")
      , width = 3),
    mainPanel(
      dataTableOutput("dto"),
      downloadButton('downloadData',"Download data")
    )))


server <- function(input, output, session) {
  
  out <- eventReactive(input$submit_loc,{
    if(is.null(input$file)) {
      return("No file selected")}
    input1 <- read.SDFset(input$file$datapath)
    input2 <- datablock2ma(datablocklist=datablock(input1))
    cas <- input2[,1]
    MF <- input2[,3]
    MF_ExactMass <- c()
    for (i in 1:length(MF)){MF_ExactMass = cbind(MF_ExactMass,getMolecule(MF[i])$exactmass)}
    ExactMass <- c(MF_ExactMass)
    cats <- input$comp_type
    ref2 <- c()
    for (i in 1:length(cats)){
      
      ref1 = ref[which(ref$Iontype == cats[i]),2]
      ref2 = cbind(ref2,ref1)
    }
    tail <- length(ref2)
    cats2 <-paste0(ref2, collapse=".")
    IonType <- c(cats2)
    output1 <- t(rbind(MF,IonType,cas,ExactMass))
    output1
  })
  
  output$dto <- renderDataTable({out()})
  
  
  
  output$downloadData <-  downloadHandler(
    filename = function() {
      paste(input$filename,".csv", sep = "")
    },
    content = function(file) {
      output2 <- as.matrix(out())
      write.csv2(output2,file, row.names = FALSE)
    }
  )}


shinyApp(ui=ui, server=server)