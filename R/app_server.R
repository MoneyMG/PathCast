#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {

  r <- shiny::reactiveValues()

  mod_Series_server("Series_1", r = r)

  mod_EDA_server("EDA_1", r = r)

}
