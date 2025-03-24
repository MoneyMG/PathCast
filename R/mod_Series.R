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
  tagList(
 
  )
}
    
#' Series Server Functions
#'
#' @noRd 
mod_Series_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
 
  })
}
    
## To be copied in the UI
# mod_Series_ui("Series_1")
    
## To be copied in the server
# mod_Series_server("Series_1")
