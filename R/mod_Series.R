#' Series UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_Series_ui <- function(id) {
  ns <- NS(id)
  series <- c('SPY', 'CL', 'CL/SYN Spread')
  tagList(
    div(
      class = 'text-center',
    tags$img(
      src = "www/astronaut-helmet3.png",
      alt = "Astronaut Helmet",
      width = "300px",
      height = "auto"
    ),
    br(),
    shiny::tags$h2("Diffusion Processes. The Initial Frontier."),
    br(),
    shiny::tags$p("In the ever-expanding universe of finance,
                  understanding how variables spread and evolve presents a key to understanding how market mechanics can be exploited.
                  This app explores the application of diffusion processes to different types of financial markets, using machine learning to estimate their behavior and
                  offer insights on how our estimations can inform trading strageties."),
    br(),
    shiny::radioButtons(ns('series'), "Select a 'Process'", choices = series, selected = 'SPY', inline = TRUE),
    br(),
    shiny::textOutput(outputId = ns('seriesmessage'))
    )
  )
}

#' Series Server Functions
#'
#' @noRd
mod_Series_server <- function(id, r){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    shiny::observeEvent(input$series, {

      r$series <- input$series

      output$seriesmessage <- shiny::renderText({
        if(input$series == 'SPY'){
        paste(input$series, "is more like the universe than you think. Head to exploratory data analysis (EDA) for an explaination.")
      }else if(input$series == 'CL'){
        paste("Much like yourself, the", input$series, "process is affected by gravitational pull. Head to exploratory data analysis (EDA) for an explaination.")
      }else{
        paste("The", input$series, "process is akin to a SAFER pack. Head to exploratory data analysis (EDA) for an explaination.")
      }
      })

      edaimage <- shiny::reactive({
        if (input$series == "SPY") {
          "www/Expanding.png"
        } else if (input$series == "CL") {
          "www/PushPull.png"
        } else {
          "www/SAFER.png"
        }
      })

      edaimage_size <- shiny::reactive({
        if (input$series == "SPY") {
          "500px"
        } else if (input$series == "CL") {
          "500px"
        } else {
          "400px"
        }
      })

      edatitle <- shiny::reactive({
        if (input$series == "SPY") {
          "Geometric Brownian Motion"
        } else if (input$series == "CL") {
          "Ornstein–Uhlenbeck"
        } else {
          "Ornstein–Uhlenbeck with Jumps"
        }
      })

      r$edaimage <- edaimage()
      r$edaimage_size <- edaimage_size()
      r$edatitle <- edatitle()

    })

  })
}

## To be copied in the UI
# mod_Series_ui("Series_1")

## To be copied in the server
# mod_Series_server("Series_1")
