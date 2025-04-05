FROM rocker/verse:4.4.2
RUN apt-get update && apt-get install -y  libcurl4-openssl-dev libicu-dev libnode-dev libssl-dev libx11-dev libxml2-dev make pandoc zlib1g-dev && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/
RUN echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl', Ncpus = 4)" | tee /usr/local/lib/R/etc/Rprofile.site | tee /usr/lib/R/etc/Rprofile.site
RUN R -e 'install.packages("remotes")'
RUN Rscript -e 'remotes::install_version("rlang",upgrade="never", version = "1.1.5")'
RUN Rscript -e 'remotes::install_version("zoo",upgrade="never", version = "1.8-13")'
RUN Rscript -e 'remotes::install_version("magrittr",upgrade="never", version = "2.0.3")'
RUN Rscript -e 'remotes::install_version("dplyr",upgrade="never", version = "1.1.4")'
RUN Rscript -e 'remotes::install_version("bslib",upgrade="never", version = "0.9.0")'
RUN Rscript -e 'remotes::install_version("scales",upgrade="never", version = "1.3.0")'
RUN Rscript -e 'remotes::install_version("tseries",upgrade="never", version = "0.10-58")'
RUN Rscript -e 'remotes::install_version("tidyr",upgrade="never", version = "1.3.1")'
RUN Rscript -e 'remotes::install_version("plotly",upgrade="never", version = "4.10.4")'
RUN Rscript -e 'remotes::install_version("ggplot2",upgrade="never", version = "3.5.1")'
RUN Rscript -e 'remotes::install_version("shiny",upgrade="never", version = "1.10.0")'
RUN Rscript -e 'remotes::install_version("config",upgrade="never", version = "0.3.2")'
RUN Rscript -e 'remotes::install_version("fabletools",upgrade="never", version = "0.5.0")'
RUN Rscript -e 'remotes::install_version("testthat",upgrade="never", version = "3.2.3")'
RUN Rscript -e 'remotes::install_version("katex",upgrade="never", version = "1.5.0")'
RUN Rscript -e 'remotes::install_version("gt",upgrade="never", version = "0.11.1")'
RUN Rscript -e 'remotes::install_version("golem",upgrade="never", version = "0.5.1")'
RUN Rscript -e 'remotes::install_version("feasts",upgrade="never", version = "0.4.1")'
RUN Rscript -e 'remotes::install_version("DT",upgrade="never", version = "0.33")'
RUN Rscript -e 'remotes::install_version("bsicons",upgrade="never", version = "0.1.2")'
RUN Rscript -e 'remotes::install_version("broom",upgrade="never", version = "1.0.7")'
RUN Rscript -e 'remotes::install_github("risktoollib/RTL@4cdf3151978c139e3308e4d336c2cd5d63138033")'
RUN mkdir /build_zone
ADD . /build_zone
WORKDIR /build_zone
RUN R -e 'remotes::install_local(upgrade="never")'
RUN rm -rf /build_zone
EXPOSE 80
CMD R -e "options('shiny.port'=80,shiny.host='0.0.0.0');library(PathCast);PathCast::run_app()"
