
<!-- README.md is generated from README.Rmd. Please edit that file -->

# <img src="https://cdn.jsdelivr.net/npm/bootstrap-icons/icons/rocket-takeoff-fill.svg" width="20"> `{PathCast}`

<!-- badges: start -->
<!-- badges: end -->

## Installation

You can install the development version of `{PathCast}` like so:

``` r
# FILL THIS IN! HOW CAN PEOPLE INSTALL YOUR DEV PACKAGE?
```

## Run

You can launch the application by running:

``` r
PathCast::run_app()
```

## About

You are reading the doc about version : 0.0.0.9000

This README has been compiled on the

``` r
Sys.time()
#> [1] "2025-03-24 16:16:14 MDT"
```

Here are the tests results and package coverage:

``` r
devtools::check(quiet = TRUE)
#> ℹ Loading PathCast
#> ── R CMD check results ──────────────────────────────── PathCast 0.0.0.9000 ────
#> Duration: 1m 34.3s
#> 
#> ❯ checking DESCRIPTION meta-information ... WARNING
#>   Non-standard license specification:
#>     What license is it under?
#>   Standardizable: FALSE
#> 
#> 0 errors ✔ | 1 warning ✖ | 0 notes ✔
#> Error: R CMD check found WARNINGs
```

``` r
covr::package_coverage()
#> PathCast Coverage: 28.85%
#> R/app_config.R: 0.00%
#> R/app_server.R: 0.00%
#> R/app_ui.R: 0.00%
#> R/run_app.R: 0.00%
#> R/mod_Series.R: 90.00%
#> R/mod_EDA.R: 100.00%
```
