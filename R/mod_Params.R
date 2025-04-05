#' Params UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom rlang sym
mod_Params_ui <- function(id) {
  ns <- NS(id)
  series <- c('SPY', 'CL01', 'CL/Syn Spread')

  tagList(
    div(
      class = 'text-center',
      tags$h1("Parameter Estimation"),
      shiny::uiOutput(ns('welcomepic')),
      br(),
      class = 'px-4',
      tags$p(
        'We’ve studied the ',
         textOutput(ns("process"), inline = TRUE),
         ' process in a vacuum — clean, controlled, predictable. But real missions aren’t flown in labs. Out here, signals get noisy, paths drift,
             and systems don’t behave by the book.',
        br(),
        'This tab is your mission brief for the chaos: what the algorithm sees and what it’s trying to decode
             as it navigates the unknown.'
      ),
     br(),
     shiny::radioButtons(ns('instrument'), "Select a Series", choices = series, inline = TRUE)
    ),
    br(),
    bslib::card(
      tags$h2('Historical Path'),
      div(plotly::plotlyOutput(ns('visualize'), width = '75%'), align = 'center')
    ),
    br(),
    shiny::uiOutput(ns('dynamix'))


  )
}

#' Params Server Functions
#'
#' @noRd
mod_Params_server <- function(id, r){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    output$process <- shiny::renderText({r$series})

    output$welcomepic <- shiny::renderUI({
      tags$img(
        src = 'www/robo.png',
        alt = "Params Image",
        width = '400',
        height = "400"
      )

      })

    data <- shiny::reactive({

      req(input$instrument)

      filter <- if(input$instrument == 'CL/Syn Spread'){
        'spread'
      }else{
        input$instrument
      }

      masterlong %>%
        dplyr::filter(series == filter)
    })

    output$visualize <- plotly::renderPlotly({

      p <- data() %>%
        ggplot2::ggplot(ggplot2::aes(x = t, y = value)) +
        ggplot2::geom_line() +
        ggplot2::theme_minimal() +
        ggplot2::scale_y_continuous(labels = scales::dollar) +
        ggplot2::labs(y = '')

      plotly::ggplotly(p)

    })


    fullset <- shiny::reactive({

      req(data(), r$drift)

      seriesspecific <- data()

      col <- ifelse(input$instrument == 'CL/Syn Spread', 'spread', input$instrument)

      seriesspecific <- seriesspecific %>%
        tibble::as_tibble() %>%
        tidyr::pivot_wider(id_cols = c(t, date), names_from = 'series', values_from = 'value')


      if(r$series == 'Geometric Brownian Motion'){

        set.seed(1234)
        nod <- RTL::simGBM(1, as.numeric(r$s0), 0, as.numeric(r$sigma), as.numeric(max(seriesspecific$t)), 1/252)
        d <- RTL::simGBM(1, as.numeric(r$s0), as.numeric(r$drift), as.numeric(r$sigma),as.numeric(max(seriesspecific$t)), 1/252) %>%
          dplyr::rename(sim1_drift = sim1)


        base <- dplyr::left_join(nod, d)

         base %>%
         dplyr::mutate(
           sim_log = log(sim1 / dplyr::lag(sim1)),
           simdrift_log = log(sim1_drift / dplyr::lag(sim1_drift))
         ) %>%
         dplyr::left_join(seriesspecific) %>%
           dplyr::mutate(
             actual_log = log(!!rlang::sym(col) / dplyr::lag(!!rlang::sym(col)))
         )
      }

    })



    output$retdist <- plotly::renderPlotly({

      dat <- fullset()

      dat <- dat %>%
        dplyr::select(sim_log, simdrift_log, actual_log) %>%
        tidyr::drop_na()

      gbm_mu <- mean(dat$sim_log, na.rm = T)
      gbm_sd <- sd(dat$sim_log, na.rm = T)
      gbmd_mu <- mean(dat$simdrift_log, na.rm = T)
      gbmd_sd <- sd(dat$simdrift_log, na.rm = T)

      distdat <- dat %>%
        tidyr::pivot_longer(cols = c(sim_log, simdrift_log, actual_log), names_to = "series", values_to = "value")

      xvals <- seq(min(distdat$value), max(distdat$value), length.out = 1000)

      ndcurve <- dnorm(xvals, mean = gbm_mu, sd = gbm_sd)
      dcurve <- dnorm(xvals, mean = gbmd_mu, sd = gbmd_sd)

      temp <- dat %>%
        plotly::plot_ly() %>%
        plotly::add_histogram(
          x = ~sim_log,
          name = "sim_log",
          opacity = 0.5,
          histnorm = "probability density",
          nbinsx = 100
        )%>% plotly::add_histogram(
          x = ~simdrift_log,
          name = "simdrift_log",
          opacity = 0.5,
          histnorm = "probability density",
          nbinsx = 100
        ) %>% plotly::add_histogram(
          x = ~actual_log,
          name = "actual_log",
          opacity = 0.5,
          histnorm = "probability density",
          nbinsx = 100
        ) %>% plotly::add_trace(
          x = xvals,
          y = ndcurve,
          type = "scatter",
          mode = "lines",
          name = "Normal - No Drift",
          line = list(color = "black", width = 2)
        )%>% plotly::add_trace(
          x = xvals,
          y = dcurve,
          type = "scatter",
          mode = "lines",
          name = paste0("Normal - Drift = ", r$drift),
          line = list(color = "red", width = 2, dash = "dash"),
          visible = 'legendonly'
        )  %>% plotly::layout(
          barmode = "overlay",
          xaxis = list(title = "Value"),
          yaxis = list(title = "Density"),
          legend = list(x = 0.7, y = 1)
        )


    })

    output$numerictests <- gt::render_gt({

      dat <- fullset()

      dat <- dat %>%
        dplyr::select(sim_log, simdrift_log, actual_log) %>%
        tidyr::drop_na() %>%
        tidyr::pivot_longer(dplyr::everything(), names_to = 'series', values_to = 'value')

      jaqs <- dat %>%
        dplyr::group_by(series) %>%
        dplyr::do(broom::tidy(tseries::jarque.bera.test(.$value))) %>%
        dplyr::select(series, p.value, method)

      shap <- dat %>%
        dplyr::group_by(series) %>%
        dplyr::do(broom::tidy(stats::shapiro.test(.$value))) %>%
        dplyr::select(series, p.value, method)

      rbind(
        jaqs,
        shap
      ) %>%
        dplyr::mutate(conclusion = dplyr::case_when(
          method == 'Jarque Bera Test' & p.value < 0.05 ~'Not Normally distributed',
          method == 'Jarque Bera Test' & p.value > 0.05 ~ 'Normally distributed',
          method == 'Shapiro-Wilk normality test' & p.value < 0.05 ~ 'Not consistent with a normal distribution',
          method == 'Shapiro-Wilk normality test' & p.value > 0.05 ~ 'consistent with a normal distribution'
        )) %>%
        gt::gt() %>%
        gt::fmt_number(
          columns = p.value,
          decimals = 4
        ) %>%
        gt::opt_table_lines()


      })


    garch_data <- shiny::reactive({

      dat <- fullset()

      garch_dat <- dat %>% dplyr::select(date, actual_log) %>% tidyr::drop_na()

      RTL::garch(garch_dat, 'data')

    })

    output$garch_actual <- shiny::renderPlot({

      dat <- fullset()

      garch_dat <- dat %>% dplyr::select(date, actual_log) %>% tidyr::drop_na()

      RTL::garch(garch_dat, 'chart')


    })

    output$drifts <- gt::render_gt({

      dat <- fullset()

      garchdat <- garch_data()


      rbar <- mean(dat$actual_log, na.rm = T)
      var <- var(dat$actual_log, na.rm = T)
      delt <- 1/252

      meanvar <- dat %>%
        dplyr::select(t, actual_log) %>%
        dplyr::mutate(rmrbar = (actual_log - rbar)^2) %>%
        dplyr::summarise(
          mean_log = mean(actual_log),
          sample_var = sum(rmrbar),
          var = var(actual_log)
        ) %>%
        dplyr::mutate(
          sample_var = sample_var * (1/ (nrow(dat) - 1)),
          meanCheck = mean_log == rbar,
          varCheck = var == sample_var
        )

      drift_numeric <- delt^(-1)*(rbar + .5 * var)

      r$dnum <- drift_numeric

      # 2. MLE

      # mu_MLE = 1/T * sum(r_t + .5 var)

      bT <- dplyr::last(dat$t)

      temp <- dat %>%
        dplyr::select(t, actual_log) %>%
        dplyr::mutate(int = actual_log + .5 * var) %>%
        dplyr::summarise(sumint = sum(int, na.rm = T)) %>%
        dplyr::mutate(mu_MLE = sumint * bT^(-1))

      drift_MLE <- dplyr::pull(temp, mu_MLE)

      r$dMLE <- drift_MLE

      drift_garch <- mean(garchdat$returns + 0.5 * garchdat$garch^2)

      r$dgarch <- drift_garch

      drifts <- c(drift_numeric, drift_MLE, drift_garch)

      drift_equations <- c(
        "$$\\mu_{\\text{num}} = \\frac{1}{\\Delta t} \\left( \\bar{r} + \\frac{1}{2} \\text{Var}(\\log r) \\right)$$",
        "$$\\mu_{\\text{MLE}} = \\frac{1}{T} \\sum_{t=1}^{T} \\left( r_t + \\frac{1}{2} \\text{Var}(\\log r) \\right)$$",
        "$$\\mu_{\\text{GARCH}} = \\frac{1}{T} \\sum_{t=1}^{T} \\left( r_t + \\frac{1}{2} \\sigma_t^2 \\right)$$"
      )

      gt::gt(tibble::tibble(Formula = drift_equations, Drift = drifts)) %>%
        gt::fmt_markdown(columns = 'Formula') %>%
        gt::fmt_number(columns = 'Drift', decimals = 4) %>%
        gt::opt_table_lines()

    })

    fits <- shiny::reactive({


      dat <- fullset()
      col <- ifelse(input$instrument == 'CL/Syn Spread', 'spread', input$instrument)
      garchdat <- garch_data()



      n <- nrow(dat)
      dt <- 1/252
      time <- seq(0, n-1, by = dt)
      s0 <- dplyr::pull(dat, !!rlang::sym(col))[1]


      set.seed(123)
      W <- cumsum(c(0, rnorm(n-1, mean = 0, sd = sqrt(dt))))

      sigma_static <- sd(dat$actual_log, na.rm = T)
      sigma_garch <- zoo::coredata(garchdat$garch)


      simnum <- s0 * exp((r$dnum - 0.5 * sigma_static^2) * time + sigma_static * W)
      simmle <- s0 * exp((r$dMLE - 0.5 * sigma_static^2) * time + sigma_static * W)
      simgarch <- s0 * exp((r$dgarch - 0.5 * sigma_static^2) * time + sigma_static * W)


      temp <- tibble::tibble(
        t = time,
        numeric_d = simnum,
        mle_d = simmle,
        garch_d = simgarch
      )

      temp

    })


    output$fits <- shiny::renderDataTable({fits()})

    output$dynamix <- shiny::renderUI({

      if(r$series == 'Geometric Brownian Motion'){
        tagList(
          bslib::layout_columns(
            widths = c(8, 8, 8, 8),
            bslib::card(
              'Quick Inspect',
              shiny::tabsetPanel(
                shiny::tabPanel(
                  'Price Distribution',
                  br(),
                  tags$p('GBM assumes Normal distribution of log daily returns'),
                  plotly::plotlyOutput(ns('retdist'))
                ),
                shiny::tabPanel(
                  'Distribution Tests',
                  gt::gt_output(ns('numerictests'))
                )

              )
              ),
            bslib::card('Volatility',
                        shiny::plotOutput(ns('garch_actual'))),
            bslib::card('Drift',
                        gt::gt_output(ns('drifts'))),
            bslib::card('Fits',
                        shiny::dataTableOutput(ns('fits'))
                        )
          )
        )
      }else{
        tags$h3('This tab is purposely blank for OU/OUJ')
      }
    })



  })
}

## To be copied in the UI
# mod_Params_ui("Params_1")

## To be copied in the server
# mod_Params_server("Params_1")
