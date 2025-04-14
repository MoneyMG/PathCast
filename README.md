
<!-- README.md is generated from README.Rmd. Please edit that file -->

# <img src="https://cdn.jsdelivr.net/npm/bootstrap-icons/icons/rocket-takeoff-fill.svg" width="20"> `{PathCast}`

<!-- badges: start -->
<!-- badges: end -->

## What is PathCast?

**PathCast** is an educational and exploratory data analysis tool
designed to support the development of machine learning frameworks -
specifically for diffusion process classification and parameter
estimation. PathCast is best used in your browser!

### PathCast has three main goals:

- **Introduce diffusion processes in an accessible way**
  - Current focus includes: Geometric Brownian Motion (GBM),
    Ornstein-Uhlenbeck (OU), and OU with jumps.
- **Highlight unique characteristics of each process**
  - What components are deterministic vs. probabilistic?  
  - What tools can help us classify a process?  
  - What assumptions underlie each model, and how can we address their
    limitations?
- **Explore how machine learning can enhance decision-making**
  - How do we quantify confidence in our classifications and parameter
    estimates?  
  - What would a manual classification process look like—and how could
    ML improve it?

### Future Development Plans

- Develop and test machine learning algorithms
  - Focus on improving process classification, parameter estimation, and
    strategy selection
- Reverse-engineer trading strategies using classified processes and
  estimated parameters
  - Understand how specific dynamics influence strategic decisions
- Use process parameters to simulate strategy performance
  - Assess robustness under different stochastic regimes
- Screen for similar processes across a market universe
  - Identify clusters of assets with comparable dynamics to build a
    diverse, tradeable strategy

## Installation

You can install the development version of `{PathCast}` like so:

``` r
devtools::install_github('MoneyMG/PathCast')
```

Docker image also available via dockerhub:

[Pathcast on Docker Hub](https://hub.docker.com/r/magad1/pathcast)

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
#> [1] "2025-04-14 10:45:45 MDT"
```

package coverage:

``` r
covr::package_coverage()
#> PathCast Coverage: 25.57%
#> R/app_config.R: 0.00%
#> R/app_server.R: 0.00%
#> R/app_ui.R: 0.00%
#> R/run_app.R: 0.00%
#> R/mod_Params.R: 14.05%
#> R/mod_Series.R: 38.67%
#> R/mod_EDA.R: 43.03%
```
