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
    shiny::tags$h2("Difussion Processes. The Initial Frontier."),
    br(),
    shiny::tags$p("In the ever-expanding universe of finance,
                  understanding how variables spread and evolve is key to unlocking new strategies.
                  This app explores the application of diffusion processes to different types of financial markets, using machine learning to estimate their behavior and
                  offer insights on how our estimations can shape trading strageties."),
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

      golem::message_dev(paste("Series selection updated:", input$series))

      output$seriesmessage <- shiny::renderText({
        if(input$series == 'SPY'){
        paste(input$series, "is more like the universe than you think. Head to exploratory data analysis (EDA) for an explaination.")
      }else if(input$series == 'CL'){
        paste("Much like you space cowboy, the", input$series, "process is affected by gravitational pull. Head to exploratory data analysis (EDA) for an explaination.")
      }else{
        paste("The", input$series, "process is akin to black holes colliding. Head to exploratory data analysis (EDA) for an explaination.")
      }
      })

    })

  })
}

## To be copied in the UI
# mod_Series_ui("Series_1")

## To be copied in the server
# mod_Series_server("Series_1")
