#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(bslib)

# Define UI for application that draws a histogram
ui <- tagList(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  navbarPage(
    title = div(
      div(
        id = 'logo-id',
        img(src = "uni_logo.png"),
        ),
        "Looking Under the Hood of Commodity Currencies"
      ),
    tabPanel('New Understandings',
    mainPanel(
      tabsetPanel(
        tabPanel('The Previous Understanding',
                 h2('Currencies blah blah...')
                 ),
        tabPanel("Tab 2", "This panel is intentionally left blank"),
        tabPanel("Tab 3", "This panel is intentionally left blank")
      )
    )
    ),
    tabPanel("Implications", "This panel is intentionally left blank"),
    tabPanel("Use Cases", "This panel is intentionally left blank")
  )
)







