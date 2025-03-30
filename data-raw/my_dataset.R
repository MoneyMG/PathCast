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

masterlong %>%
  ggplot(aes(x = date, y = value, col = series)) + geom_line()

eda_text <-
  tibble::tibble(
    id <- c('geo', 'OU', 'OUJ')
  )


usethis::use_data(spy_data, spread_data, cl01_data, masterlong, overwrite = TRUE)
