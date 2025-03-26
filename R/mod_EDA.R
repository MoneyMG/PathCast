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
      uiOutput(ns("source")),
      br(),
      tags$h1(shiny::textOutput(ns('title')))
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
      req(r$edaimage)  # Ensure `r$edaimage` is not NULL
      tags$img(
        src = r$edaimage,  # Use the reactive image path
        alt = "EDA Image",
        width = r$edaimage_size,
        height = "auto"
      )
    })

    output$title <- shiny::renderText(r$edatitle)
  })
}


## To be copied in the UI
# mod_EDA_ui("EDA_1")

## To be copied in the server
# mod_EDA_server("EDA_1")
