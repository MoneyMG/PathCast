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
       div(shiny::uiOutput(ns('inputs')), align = 'center'),
       div(plotly::plotlyOutput(ns('idealprocess'), width = '75%'), align = 'center')
        ),
    br(),
    bslib::layout_columns(
      style = "padding-top: 5px;",
      col_widths = c(8, 4),
      bslib::card(
        bslib::card_header(tags$h2('What are our Cues?')),
          shiny::tabsetPanel(
            shiny::tabPanel('Numerically',
                            gt::gt_output(ns('gt')),
                            br(),
                            div(
                              class = 'text-center',
                              tags$h3('Quetions that concern our algo:'),
                              tags$p('What makes this process distinct?'),
                              tags$p('What is deterministic/probabilistic?'),
                              tags$p('Does this imply any shortcuts?')
                            )
            ),shiny::tabPanel('Components',
                              br(),
                              div(class = 'text-center', tags$p('Our Algo wont have labels either, how could you tell what your looking at?')),
                              br(),
                              shiny::uiOutput(ns('driftui')),
                              shiny::plotOutput(ns('components'))


            ),shiny::tabPanel('The left overs',
                            br(),
                            div(class = 'text-center', tags$p('What we should see if our model is 100% successful')),
                            shiny::plotOutput(ns('qq')),
                            div(class = 'text-center', tags$p('How much data do we need to be conclusive in our tests? (T2M/dt)')),
                            gt::gt_output(ns('tests'))

            )
          ),
        style = "padding: 20px;"
      ),
      bslib::card(
        bslib::card_header(tags$h2('What problems will we have to overcome?')),
        div(
          style = "padding-top: 5rem;",
          shiny::uiOutput(ns('modiffusionmoproblems'))
        ),
        style = "padding: 20px;"
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

    # data <- shiny::reactive({
    #   if(r$series == 'SPY'){
    #     spy_data
    #   }else if(r$series == 'CL/SYN Spread'){
    #     spread_data
    #   }else{
    #     cl01_data
    #   }
    #
    # })

    initparams <- shiny::reactive({
      if(r$series == 'Geometric Brownian Motion'){
        c(100, 100, 0, 0.2, 1, 1/12)
      }else if(r$series == 'Ornstein-Uhlenbeck (OU)'){
        c(100, 10, 11, 1, 0.2, 3, 1/12)
      }else{
        c(100, 10, 11, 1, 0.2, 0.05, 2, 0.05, 1, 1/12)
      }
    })


    output$inputs <- shiny::renderUI({

      params <- initparams()

      if (r$series == 'Geometric Brownian Motion') {
        tagList(
          shiny::fluidRow(
            shiny::column(3, shiny::numericInput(ns("S0"), "Initial Price ($)", value = params[2])),
            shiny::column(3, shiny::numericInput(ns("sigma"), "Volatility (decimal form, 0.2 = 20%)", value = params[4], step = 0.01)),
            shiny::column(3, shiny::numericInput(ns("T2M"), "Time to Maturity (yrs)", value = params[5])),
            shiny::column(3, shiny::numericInput(ns("dt"), "Time Step (fraction of yr, 0.083 = 1 Month)", value = params[6]))
          )
        )
      }else if(r$series == 'Ornstein-Uhlenbeck (OU)'){
        tagList(
          shiny::fluidRow(
            shiny::column(3, shiny::numericInput(ns("S0"), "Initial Price ($)", value = params[2])),
            shiny::column(3, shiny::numericInput(ns("mu"), "Mean ($)", value = params[3])),
            shiny::column(3, shiny::numericInput(ns("theta"), "Reversion Speed (Time Steps)", value = params[4])),
            shiny::column(3, shiny::numericInput(ns("sigma"), "Volatility (decimal form, 0.2 = 20%)", value = params[5], step = 0.01)),
            shiny::column(3, shiny::numericInput(ns("T2M"), "Time to Maturity (yrs)", value = params[6])),
            shiny::column(3, shiny::numericInput(ns("dt"), "Time Step (fraction of yr, 0.083 = 1 Month)", value = params[7]))
          )
        )
      }else{
        tagList(
          tags$p('See Ornstein-Uhlenbeck (OU) for underlying OU process'),
          shiny::fluidRow(
            shiny::column(3, shiny::numericInput(ns("theta"), "Reversion Speed (Time Steps)", value = params[4])),
            shiny::column(3, shiny::numericInput(ns("lambda"), "Jump Probability (decimal form, 0.05 = 5%)", value = params[6])),
            shiny::column(3, shiny::numericInput(ns("mu_jump"), "Mean Jump Size ($)", value = params[7])),
            shiny::column(3, shiny::numericInput(ns("sd_jump"), "Jump Standard Deviation (decimal form, 0.05 = 5%)", value = params[8])),
            shiny::column(3, shiny::numericInput(ns("T2M"), "Time to Maturity (yrs)", value = params[9])),
            shiny::column(3, shiny::numericInput(ns("dt"), "Time Step (fraction of yr, 0.083 = 1 Month)", value = params[10]))
          )
        )
      }
    })

    data <- shiny::reactive({
      params <- initparams()

      if(r$series == 'Geometric Brownian Motion'){
        set.seed(1234)
        RTL::simGBM(params[1], input$S0, params[3], input$sigma, input$T2M, input$dt)
        }
      else if(r$series == 'Ornstein-Uhlenbeck (OU)'){
        set.seed(1234)
        RTL::simOU(params[1], input$S0, input$mu, input$theta, input$sigma, input$T2M, input$dt)
      }
      else{
        set.seed(1234)
        RTL::simOUJ(params[1], params[2], params[3], input$theta, params[5], input$lambda, input$mu_jump, input$sd_jump, input$T2M, input$dt)
      }
    })

    ts <- shiny::reactive({

      d <- data()

      ts <- d %>%
        dplyr::select(t, sim1) %>%
        dplyr::mutate(fd = sim1 - dplyr::lag(sim1)) %>%
        tidyr::drop_na() %>%
        dplyr::select(t, fd) %>%
        tsibble::as_tsibble(index = t)

    })

    basegraph <- shiny::reactive({

      dat <- data()

       dat %>%
          tidyr::pivot_longer(-t, names_to = 'series', values_to = 'value') %>%
          ggplot2::ggplot(ggplot2::aes(x = t, y = value, col = series)) +
          ggplot2::geom_line() +
          ggplot2::theme_minimal() +
          ggplot2::scale_y_continuous(labels = scales::dollar) +
          ggplot2::labs(
            y = 'Price'
          )

    })

    output$idealprocess <- plotly::renderPlotly(plotly::ggplotly(basegraph()) %>% plotly::layout(showlegend = FALSE))

    gt <- shiny::reactive({

        temp <- eda_markdown %>%
          dplyr::filter(id == r$series) %>%
          dplyr::select(-id)


          temp %>%
          gt::gt() %>%
          gt::fmt_markdown(columns = c('Continuous', 'Discrete')) %>%
          gt::opt_table_lines()

          })

    output$gt <- gt::render_gt(gt())

    output$qq <- shiny::renderPlot({

      d <- data()

      sim1 <-  d %>%
        dplyr::select(t, sim1) %>%
        dplyr::mutate(fd = sim1 - dplyr::lag(sim1)) %>%
        tidyr::drop_na()

      stats::qqnorm(sim1$fd, main = "Simulated Series 1 First Difference - Normal Q-Q Plot")
      stats::qqline(sim1$fd, col = "red")

    })


    tests <- shiny::reactive({

      ts <- ts()

      temp <- rbind(
        broom::tidy(tseries::kpss.test(ts$fd, 'Level')),
        broom::tidy(tseries::kpss.test(ts$fd, 'Trend')),
        broom::tidy(stats::Box.test(as.numeric(ts$fd), lag = 1, type = 'Ljung-Box'))
      ) %>%
        dplyr::mutate(conclusion  = ifelse(p.value > 0.05, 'Accept Null', 'Reject Null')) %>%
        dplyr::mutate(meaning = dplyr::case_when(
          method == 'Box-Ljung test' & conclusion == 'Reject Null' ~ 'First difference has structure',
          method == 'Box-Ljung test' & conclusion == 'Accept Null' ~ 'First difference Produces White Noise',
          method == 'KPSS Test for Level Stationarity' & conclusion == 'Accept Null' ~ 'First difference is level stationary',
          method == 'KPSS Test for Level Stationarity' & conclusion == 'Reject Null' ~ 'First difference is not level stationary',
          method == 'KPSS Test for Trend Stationarity' & conclusion == 'Accept Null' ~ 'First difference is trend stationary',
          method == 'KPSS Test for Trend Stationarity' & conclusion == 'Reject Null' ~ 'First difference is not trend stationary',
        ))

      temp %>%
        dplyr::rename_with(., .fn = ~stringr::str_to_title(.)) %>%
        gt::gt() %>%
        gt::opt_table_lines() %>%
        gt::fmt_number(
          columns = c('Statistic', 'P.value'),
          decimals = 4
        )
    })


    output$driftui <- shiny::renderUI({
      if (r$series == 'Geometric Brownian Motion') {
        shiny::numericInput(ns("drift"), "Drift", value = 0.01, step = 0.01)
      }
    })

    components <- shiny::reactive({

      ts <- ts()

      if(r$series == 'Geometric Brownian Motion'){

        params <- initparams()

        set.seed(1234)
        drift <- RTL::simGBM(1, input$S0, input$drift, input$sigma, input$T2M, input$dt) %>%
          dplyr::rename(sim1_drift = sim1)

        ts <- ts %>%
          dplyr::left_join(drift)

      }

      ts %>%
        tidyr::pivot_longer(-t, names_to = 'series', values_to = 'value') %>%
        tsibble::group_by_key() %>%
        fabletools::model(
          feasts::STL(formula = value ~ season(window = input$dt + input$dt))
        ) %>% fabletools::components()

    })

    output$components <- shiny::renderPlot({
      components() %>% feasts::autoplot() + ggplot2::theme(legend.position = 'none')
      })



    output$tests <- gt::render_gt(tests())

    output$modiffusionmoproblems <- shiny::renderUI({

      text <- eda_problems %>%
        dplyr::filter(id == r$series) %>%
        dplyr::pull(problems)


      shiny::HTML(text)
    })

  })
}


## To be copied in the UI
# mod_EDA_ui("EDA_1")

## To be copied in the server
# mod_EDA_server("EDA_1")
