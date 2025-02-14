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
library(plotly)

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
    fluidPage(
      tabsetPanel(
        tabPanel("Defining Commodity-Exposed Currencies",
                 div(class = "centered-content",
                      uiOutput("historical_text")
                 )
                 ),
        tabPanel("Applying the Definition",
                 sidebarLayout(
                   sidebarPanel(
                     selectInput("Type", "Choose Beta Strength", choices = c("Strongly Positive", "Moderately Postive", "Slightly Postive"), selected = "Moderately Positive")
                   ),
                 mainPanel(
                 h2(strong('Static Beta')),
                 h3(strong('Feb 1992 - July 2024')),
                 br(),
                 textOutput('importer_reg_sup'),
                 br(),
                 plotlyOutput("importer_reg"),
                 br(),
                 textOutput('segway'),
                 br(),
                 h2(strong('Under The Hood')), #change this
                 br(),
                 plotlyOutput("alt_beta"),
                 br(),
                 textOutput('ident_real')
                 )
                 )
        )
      )
    )
    ),
    tabPanel("Implications", "This panel is intentionally left blank"),
    tabPanel("Use Cases", "This panel is intentionally left blank")
  )
)







