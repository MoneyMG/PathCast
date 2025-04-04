## code to prepare `my_dataset` dataset goes here
library(tidyverse)
library(RTL)

# spread data needs to be called first as the most constrained in terms of date range. All sets will be relative to spread dat for comparasion

spread_data <- RTL::fizdiffs %>%
  dplyr::mutate(spread = SYN.EDM - (WCS.HDY + CL.EDM)) %>%
  dplyr::select(date, spread) %>%
  dplyr::mutate(i = dplyr::row_number() -1,
                t = i / 252) %>%
  dplyr::select(t, date, spread) %>%
  tidyr::pivot_longer(-c(t, date), names_to = 'series', values_to = 'value')

spy_data <- tidyquant::tq_get(
  'SPY',
  get = 'stock.prices',
  from = min(spread_data$date),
  to = max(spread_data$date)
) %>%
  dplyr::select(date, adjusted) %>%
  dplyr::rename('SPY' = adjusted) %>%
  tidyr::pivot_longer(-date, names_to = 'series', values_to = 'value') %>%
  dplyr::mutate(i = row_number() -1,
                t = i / 252) %>%
  dplyr::select(t, date, series, value) %>%
  tidyr::drop_na()



cl01_data <- RTL::dflong %>%
  dplyr::filter(series == 'CL01' & date >= min(spread_data$date) & date <= max(spread_data$date)) %>%
  dplyr::mutate(i = dplyr::row_number() -1,
                t = i / 252) %>%
  dplyr::select(t, date, series, value)

masterlong <- dplyr::bind_rows(spread_data, spy_data, cl01_data)



eda_text <-
  tibble::tibble(
    id = c('SPY', 'CL01', 'CL/SYN Spread'),
    explaination = c(
      'Just as the universe, shaped by initial conditions and influenced by random events, evolves in a complex, probabilistic manner,
      financial assets move within a framework of historical influences, market forces, and unpredictable shocks. While the path may be informed by past data,
      the future remains uncertain, shaped by both deterministic factors and inherent randomness.',
      'The OU process models a system that fluctuates around a long-term mean, much like how gravity pulls objects toward equilibrium.
      Think of planets oscillating in their orbits or galaxies being drawn toward their local clusters.
      If GBM is the chaotic expansion of the universe, OU is the stabilizing force that brings order to the chaos',
      'A Simplified Aid for EVA Rescue (SAFER) pack is used in case an astronaut is subjected to a shock that pushes them far away from the space craft.
       It uses small thrusters to propel the astronaut back — just like how the mean-reverting force (θ) in an OU process pulls
      a system toward equilibrium. However, just as unexpected bursts or external forces can cause abrupt disruptions in space, random jumps in an OUJ process introduce sudden
      deviations before the system stabilizes again.'
    )
  )

eda_markdown <-
  tibble::tibble(
    id = c('SPY', 'SPY', 'CL01', 'CL/SYN Spread'),
    Process = c('GBM', 'GBM_d', 'OU', 'OUJ'),
    Continuous = c(
      "$dS_t = \\mu S_t dt + \\sigma S_t dW_t$",
      "$dS_t = (\\mu S_t + \\theta) dt + \\sigma S_t dW_t$",
      "$dX_t = \\theta (\\mu - X_t) dt + \\sigma dW_t$",
      "$dX_t = \\theta (\\mu - X_t) dt + \\sigma dW_t + J dN_t$"
    ),
    Discrete = c(
      "$S_{t+1} = S_t \\exp\\left( \\mu \\Delta t + \\sigma \\sqrt{\\Delta t} Z_t \\right)$",
      "$S_{t+1} = S_t \\exp\\left( (\\mu + \\theta) \\Delta t + \\sigma \\sqrt{\\Delta t} Z_t \\right)$",
      "$X_{t+1} = X_t e^{-\\theta \\Delta t} + \\mu (1 - e^{-\\theta \\Delta t}) + \\sigma \\sqrt{\\frac{1 - e^{-2\\theta \\Delta t}}{2\\theta}} Z_t$",
      "$X_{t+1} = X_t e^{-\\theta \\Delta t} + \\mu (1 - e^{-\\theta \\Delta t}) + \\sigma \\sqrt{\\frac{1 - e^{-2\\theta \\Delta t}}{2\\theta}} Z_t + J_t N_t$"
    )

  )

eda_markdown %>%
  dplyr::select(-id) %>%
  gt::gt() %>%
  gt::fmt_markdown(columns = c('Continuous', 'Discrete')) %>%
  gt::tab_spanner(
    label = "Formula",
    columns = c('Continuous', 'Discrete')
  ) %>%
  gt::opt_table_lines()

usethis::use_data(spy_data, spread_data, cl01_data, masterlong, overwrite = TRUE)

usethis::use_data(eda_text, eda_markdown, overwrite = T)

