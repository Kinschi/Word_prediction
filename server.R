library(shiny)
library(ANLP)

# Reading the data
ngrams <- readRDS("ngrams.RDS")

# Server function
shinyServer(function(input,output){

prediction <- reactive({
  text <- input$text
  word_predicted <- predict_Backoff(text,ngrams)})

output$pred1 <- renderText({
  prediction()[1]})})