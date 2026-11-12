# 02-tags.R

library(shiny)

ui <- fluidPage(
  h1("My Shiny App"),
  hr(),
  p(style = "font-family:Impact",
    "See other apps in",
    a("RStudio",
      href = "https://shiny.rstudio.com/")
  )
)

server <- function(input, output){}

shinyApp(ui = ui, server = server)