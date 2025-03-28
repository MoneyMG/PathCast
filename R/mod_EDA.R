#' EDA UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_EDA_ui <- function(id) {
  ns <- NS(id)
  tagList(
    div(
      class = 'text-center',
      tags$h1(shiny::textOutput(ns('title'))),
      br(),
      uiOutput(ns("source")),
      DT::DTOutput(ns('data'))
    )
  )
}

#' EDA Server Functions
#'
#' @noRd
mod_EDA_server <- function(id, r){
  moduleServer(id, function(input, output, session){

    ns <- session$ns

    output$source <- shiny::renderUI({
      req(r$edaimage)
      tags$img(
        src = r$edaimage,
        alt = "EDA Image",
        width = r$edaimage_size,
        height = "auto"
      )
    })

    output$title <- shiny::renderText(r$edatitle)

    data <- shiny::reactive({
      if(r$series == 'SPY'){
        spy_data
      }else if(r$series == 'CL/SYN Spread'){
        spread_data
      }else{
        cl01_data
      }


    })

    shiny::observe({
      r$data <- data()
      r$ts <- data() %>%
        dplyr::select(t)

    })

    output$data <- shiny::renderDataTable(r$data)
  })
}


## To be copied in the UI
# mod_EDA_ui("EDA_1")

## To be copied in the server
# mod_EDA_server("EDA_1")
