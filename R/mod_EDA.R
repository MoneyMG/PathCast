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
      tags$p(shiny::textOutput(ns('explaination')))
    ),
    br(),
    bslib::card(
       bslib::card_header(tags$h2('Process in a Vaccum')),
       shiny::uiOutput(ns('inputs')),
       plotly::plotlyOutput(ns('idealprocess'))
        ),
    br(),
    bslib::layout_columns(
      style = "padding-top: 5px;",
      col_widths = c(6, 6),
      bslib::card(
        bslib::card_header(tags$h2('What are our Cues?')),
          shiny::tabsetPanel(
            shiny::tabPanel('Numerically',
                            gt::gt_output(ns('gt')),
                            br(),
                            div(
                              class = 'text-center',
                              tags$p('What makes this distinct?'),
                              tags$p('What is deterministic/probabilistic?'),
                              tags$p('Does this imply any shortcuts our algo should seek?')
                            )
            )
          )
      ),
      bslib::card(
        bslib::card_header(tags$h2('What problems will we have to overcome?')),
        tags$p('Placeholder')
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
    output$explaination <- shiny::renderText(r$eda_explanation)

    data <- shiny::reactive({
      if(r$series == 'SPY'){
        spy_data
      }else if(r$series == 'CL/SYN Spread'){
        spread_data
      }else{
        cl01_data
      }

    })

    initparams <- shiny::reactive({
      if(r$series == 'SPY'){
        c(100, 100, 0, 0.2, 1, 1/12)
      }else if(r$series == 'CL01'){
        c(100, 10, 11, 1, 0.2, 3, 1/12)
      }else{
        c(100, 10, 11, 1, 0.2, 0.05, 2, 0.05, 1, 1/12)
      }
    })


    output$inputs <- shiny::renderUI({

      params <- initparams()

      if (r$series == "SPY") {
        tagList(
          shiny::fluidRow(
            shiny::column(3, shiny::numericInput(ns("S0"), "Initial Price (S0)", value = params[2])),
            shiny::column(3, shiny::numericInput(ns("sigma"), "Volatility (sigma)", value = params[4])),
            shiny::column(3, shiny::numericInput(ns("T2M"), "Time to Maturity (T2M)", value = params[5])),
            shiny::column(3, shiny::numericInput(ns("dt"), "Time Step (dt)", value = params[6]))
          )
        )
      }else if(r$series == 'CL01'){
        tagList(
          shiny::fluidRow(
            shiny::column(3, shiny::numericInput(ns("S0"), "Initial Price (S0)", value = params[2])),
            shiny::column(3, shiny::numericInput(ns("mu"), "Mean (mu)", value = params[3])),
            shiny::column(3, shiny::numericInput(ns("theta"), "Reversion Speed (theta)", value = params[4])),
            shiny::column(3, shiny::numericInput(ns("sigma"), "Volatility (sigma)", value = params[5])),
            shiny::column(3, shiny::numericInput(ns("T2M"), "Time to Maturity (T2M)", value = params[6])),
            shiny::column(3, shiny::numericInput(ns("dt"), "Time Step (dt)", value = params[7]))
          )
        )
      }else{
        tagList(
          tags$p('See series CL01 for underlying OU process'),
          shiny::fluidRow(
            shiny::column(3, shiny::numericInput(ns("theta"), "Reversion Speed (theta)", value = params[4])),
            shiny::column(3, shiny::numericInput(ns("lambda"), "Jump Probability (lambda)", value = params[6])),
            shiny::column(3, shiny::numericInput(ns("mu_jump"), "Mean Jump Size", value = params[7])),
            shiny::column(3, shiny::numericInput(ns("sd_jump"), "Jump Standard Deviation", value = params[8])),
            shiny::column(3, shiny::numericInput(ns("T2M"), "Time to Maturity (T2M)", value = params[9])),
            shiny::column(3, shiny::numericInput(ns("dt"), "Time Step (dt)", value = params[10]))
          )
        )
      }
    })

    basegraph <- shiny::reactive({

      params <- initparams()

      if(r$series == 'SPY'){

        set.seed(1234)

        RTL::simGBM(params[1], input$S0, params[3], input$sigma, input$T2M, input$dt) %>%
          tidyr::pivot_longer(-t, names_to = 'series', values_to = 'value') %>%
          ggplot2::ggplot(ggplot2::aes(x = t, y = value, col = series)) +
          ggplot2::geom_line() +
          ggplot2::theme_minimal() +
          ggplot2::scale_y_continuous(labels = scales::dollar) +
          ggplot2::labs(
            y = 'Price'
          )
      }else if(r$series == 'CL01'){

        set.seed(1234)

        RTL::simOU(params[1], input$S0, input$mu, input$theta, input$sigma, input$T2M, input$dt) %>%
          tidyr::pivot_longer(-t, names_to = 'series', values_to = 'value') %>%
          ggplot2::ggplot(ggplot2::aes(x = t, y = value, col = series)) +
          ggplot2::geom_line() +
          ggplot2::theme_minimal() +
          ggplot2::scale_y_continuous(labels = scales::dollar) +
          ggplot2::labs(
            y = 'Price'
          )

      }else{

        set.seed(1234)

        RTL::simOUJ(params[1], params[2], params[3], input$theta, params[5], input$lambda, input$mu_jump, input$sd_jump, input$T2M, input$dt) %>%
          tidyr::pivot_longer(-t, names_to = 'series', values_to = 'value') %>%
          ggplot2::ggplot(ggplot2::aes(x = t, y = value, col = series)) +
          ggplot2::geom_line() +
          ggplot2::theme_minimal() +
          ggplot2::scale_y_continuous(labels = scales::dollar) +
          ggplot2::labs(
            y = 'Price'
          )
      }
    })

    output$idealprocess <- plotly::renderPlotly(plotly::ggplotly(basegraph()) %>% plotly::layout(showlegend = FALSE))

    gt <- shiny::reactive({

        temp <- eda_markdown %>%
          dplyr::filter(id == r$series) %>%
          dplyr::select(-id)


          temp %>%
          gt::gt() %>%
          gt::fmt_markdown(columns = 'Formula')

          })

    output$gt <- gt::render_gt(gt())



  })
}


## To be copied in the UI
# mod_EDA_ui("EDA_1")

## To be copied in the server
# mod_EDA_server("EDA_1")
