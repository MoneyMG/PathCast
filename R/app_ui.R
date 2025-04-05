#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    navbarPage(
      title = tagList(bsicons::bs_icon("rocket-takeoff"), "PathCast"),
      tabPanel("Process Selection", mod_Series_ui("Series_1")),
      tabPanel("EDA", mod_EDA_ui("EDA_1")),
      tabPanel("Parameter Estimation", mod_Params_ui("Params_1"))
    )

  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    tags$style(HTML("
      @import url('https://fonts.googleapis.com/css2?family=Raleway:ital,wght@0,100..900;1,100..900&display=swap');
      * {
        font-family: 'Raleway', sans-serif !important;
      }
    ")),
    favicon(
      ico = "PathCast",
      rel = "shortcut icon",
      resources_path = "www",
      ext = "ico"
    ),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "PathCast"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
