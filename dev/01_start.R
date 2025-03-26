# Building a Prod-Ready, Robust Shiny Application.
#
# README: each step of the dev files is optional, and you don't have to
# fill every dev scripts before getting started.
# 01_start.R should be filled at start.
# 02_dev.R should be used to keep track of your development during the project.
# 03_deploy.R should be used once you need to deploy your app.
#
#
########################################
#### CURRENT FILE: ON START SCRIPT #####
########################################

## Fill the DESCRIPTION ----
## Add meta data about your application and set some default {golem} options
##
## /!\ Note: if you want to change the name of your app during development,
## either re-run this function, call golem::set_golem_name(), or don't forget
## to change the name in the app_sys() function in app_config.R /!\
##
golem::fill_desc(
  pkg_name = "PathCast",
  pkg_title = "A Look at How to Leverage Machine Learning to Estimate Difussion Processes",
  pkg_description = "PathCast is a golem app that is deployable from your command line. The app looks at 3 distintic diffusion processes and their characterisictics. After a visual
                      inspection of their characteristics, it then looks if there any preprocessing necassary before running through a machine learning process. Finally
                      it provides a visual representation of the ML performance.",
  authors = person(
    given = "Mitch",
    family = "Greer",
    email = "magreer@ualberta.ca", # Your email
    role = c("aut", "cre") # Your role (here author/creator)
  ),
  repo_url = NULL, # The URL of the GitHub repo (optional),
  pkg_version = "0.0.0.9000", # The version of the package containing the app
  set_options = TRUE # Set the global golem options
)
## Install the required dev dependencies ----
golem::install_dev_deps()

## Create Common Files ----
## See ?usethis for more information
usethis::use_proprietary_license(copyright_holder = "Mitch Greer")
golem::use_readme_rmd(open = FALSE)
devtools::build_readme()
# Note that `contact` is required since usethis version 2.1.5
# If your {usethis} version is older, you can remove that param
usethis::use_code_of_conduct(contact = "Golem User")
usethis::use_lifecycle_badge("Experimental")
usethis::use_news_md(open = FALSE)

## Init Testing Infrastructure ----
## Create a template for tests
golem::use_recommended_tests()

## Favicon ----
# If you want to change the favicon (default is golem's one)
golem::use_favicon(path = "inst/app/www/PathCast.ico") # path = "path/to/ico". Can be an online file.
# golem::remove_favicon() # Uncomment to remove the default favicon

## Add helper functions ----
golem::use_utils_ui(with_test = TRUE)
golem::use_utils_server(with_test = TRUE)

## Use git ----
usethis::use_github("origin", url = NULL, overwrite = TRUE)


# You're now set! ----

# go to dev/02_dev.R
rstudioapi::navigateToFile("dev/02_dev.R")
