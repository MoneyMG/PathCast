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
      tags$img(
        src = ns('source'),
        alt = ns('source'),
        width = "300px",
        height = "auto"
      )
    )
  )
}

#' EDA Server Functions
#'
#' @noRd
mod_EDA_server <- function(id, r){
  moduleServer(id, function(input, output, session){

    ns <- session$ns




  })
}

## To be copied in the UI
# mod_EDA_ui("EDA_1")

## To be copied in the server
# mod_EDA_server("EDA_1")
