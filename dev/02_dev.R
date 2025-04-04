# Building a Prod-Ready, Robust Shiny Application.
#
# README: each step of the dev files is optional, and you don't have to
# fill every dev scripts before getting started.
# 01_start.R should be filled at start.
# 02_dev.R should be used to keep track of your development during the project.
# 03_deploy.R should be used once you need to deploy your app.
#
#
###################################
#### CURRENT FILE: DEV SCRIPT #####
###################################

# Engineering

## Dependencies ----
## Amend DESCRIPTION with dependencies read from package code parsing
## install.packages('attachment') # if needed.
attachment::att_amend_desc()
usethis::use_package("bslib")
usethis::use_package("bsicons")
usethis::use_package("feasts")
usethis::use_package("fabletools")
usethis::use_package("shiny")
usethis::use_package("RTL")
usethis::use_package("dplyr")
usethis::use_package("tidyr")
usethis::use_package("ggplot2")
usethis::use_package("scales")
usethis::use_package("plotly")
usethis::use_package("zoo")
usethis::use_package("tseries")
usethis::use_package('magrittr')
usethis::use_package('broom')
usethis::use_package('gt')
usethis::use_package("katex", min_version = "1.4.1")
usethis::use_package('rlang')
usethis::use_package('rugarch')

## Add modules ----


# Process Modules

golem::add_module(name = "Series", with_test = TRUE)
golem::add_module(name = "EDA", with_test = TRUE)
golem::add_module(name = "Params", with_test = TRUE)
# golem::add_module(name = "name_of_module2", with_test = TRUE) # Name of the module

## Add helper functions ----
## Creates fct_* and utils_*
golem::add_fct("helpers", with_test = TRUE)
golem::add_utils("helpers", with_test = TRUE)

## External resources
## Creates .js and .css files at inst/app/www
golem::add_css_file("pathcast_styling.css", dir = "inst/app/www")


## Add internal datasets ----
## If you have data in your package
usethis::use_data_raw(name = "my_dataset", open = FALSE)

## Tests ----
## Add one line by test you want to create
usethis::use_test("app")

# Documentation

## Vignette ----
usethis::use_vignette("PathCast")
devtools::build_vignettes()

## Code Coverage----
## Set the code coverage service ("codecov" or "coveralls")
usethis::use_coverage()

# Create a summary readme for the testthat subdirectory
covrpage::covrpage()

## CI ----
## Use this part of the script if you need to set up a CI
## service for your application
##
## (You'll need GitHub there)
usethis::use_github()

# GitHub Actions
usethis::use_github_action()
# Chose one of the three
# See https://usethis.r-lib.org/reference/use_github_action.html
usethis::use_github_action_check_release()
usethis::use_github_action_check_standard()
usethis::use_github_action_check_full()
# Add action for PR
usethis::use_github_action_pr_commands()

# Circle CI
usethis::use_circleci()
usethis::use_circleci_badge()

# Jenkins
usethis::use_jenkins()

# GitLab CI
usethis::use_gitlab_ci()

# You're now set! ----
# go to dev/03_deploy.R
rstudioapi::navigateToFile("dev/03_deploy.R")
