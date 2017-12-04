library(shiny)

shinyUI(fluidPage(
  titlePanel("Prediction app"),
  sidebarLayout(
sidebarPanel(
  textInput("text", "Type in some words here in order to get a next word prediction."),
  submitButton("Submit")
),

mainPanel(
  h3("The next word predicted is:"),
          textOutput("pred1")
  
))))

