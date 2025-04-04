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

eda_problems <-
  tibble::tibble(
    id = c('SPY', 'CL01', 'CL/SYN Spread'),
    problems = c(

      "<ul>
        <li style='margin-bottom: 1.5em;'>True GBM rarely is expressed in reality, but over the short term its behavior could manifest.</li>
        <li style='margin-bottom: 1.5em;'>How we define drift can drastically affect estimated parameters.</li>
        <li style='margin-bottom: 1.5em;'>Real-world price movements exhibit fat tails, autocorrelation, and mean reversion—all of which violate the pure GBM assumptions.</li>
        <li style='margin-bottom: 1.5em;'>ML models may conflate drift (μ) with stochastic volatility (σ), especially over short time horizons.</li>
        <li style='margin-bottom: 1.5em;'>Many ML models assume stationarity, but GBM has a non-stationary mean (it trends over time).</li>
        <li style='margin-bottom: 1.5em;'>Limited data granularity can obscure the continuous-time nature of GBM, leading to estimation errors.</li>
        <li style='margin-bottom: 1.5em;'>Models trained on historical data may fail to adapt to structural breaks or regime shifts in financial markets.</li>
      </ul>
      ",

      "<ul>
        <li style='margin-bottom: 1.5em;'>OU processes are mean-reverting by design, but estimating the speed of mean reversion (θ) can be sensitive to time scale and noise.</li>
        <li style='margin-bottom: 1.5em;'>Financial time series often exhibit regime shifts, making the assumption of a single long-term mean (μ) problematic.</li>
        <li style='margin-bottom: 1.5em;'>ML models may overfit local trends and fail to capture the global mean-reverting structure of the process.</li>
        <li style='margin-bottom: 1.5em;'>Discrete observations of a continuous OU process can obscure the underlying dynamics, especially at lower sampling frequencies.</li>
        <li style='margin-bottom: 1.5em;'>Non-linearities in real-world mean reversion may not be well captured by the linear OU formulation.</li>
        <li style='margin-bottom: 1.5em;'>Parameter estimation for OU models can be biased in the presence of market microstructure noise or illiquidity.</li>
        <li style='margin-bottom: 1.5em;'>Many ML models assume i.i.d. observations, which conflicts with the autocorrelated structure of OU processes.</li>
      </ul>
      "
      ,
      "
      <ul>
        <li style='margin-bottom: 1.5em;'>OUJ processes introduce discontinuities through jumps, making the likelihood surface complex and harder to optimize.</li>
        <li style='margin-bottom: 1.5em;'>Estimating jump intensity, size distribution, and mean reversion simultaneously increases model complexity and identifiability issues.</li>
        <li style='margin-bottom: 1.5em;'>ML models may confuse large jumps with changes in the mean-reverting level, mischaracterizing both long-term behavior and noise.</li>
        <li style='margin-bottom: 1.5em;'>Sparse jump events require large datasets to estimate reliably, but financial data is often limited or irregular.</li>
        <li style='margin-bottom: 1.5em;'>Most standard ML architectures are not designed to detect or model jump discontinuities without specialized preprocessing or architecture tweaks.</li>
        <li style='margin-bottom: 1.5em;'>OUJ processes violate the continuous-path assumption underlying many ML models trained on smoothed or stationary data.</li>
        <li style='margin-bottom: 1.5em;'>Hyperparameter tuning becomes more difficult as jump dynamics interact non-linearly with diffusion and drift components.</li>
      </ul>
      "



    )
  )



usethis::use_data(spy_data, spread_data, cl01_data, masterlong, overwrite = TRUE)

usethis::use_data(eda_text, eda_markdown, eda_problems, overwrite = T)

